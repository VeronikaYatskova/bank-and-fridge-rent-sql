-- Покажи мне список банков у которых есть филиалы в городе X

SELECT DISTINCT CONVERT(VARCHAR(MAX), Filial.name) AS Bank FROM Filial
	JOIN City ON City.id = Filial.city_id
WHERE Upper(City.name) = Upper('Homiel')

-- Получить список карточек с указанием имени владельца, баланса и названия банка

SELECT cc.credit_card_id, c.name, cc.balance, a.bank_id FROM Credit_Card AS cc
	JOIN Account AS a ON a.id = cc.account_id 
	JOIN Customer AS c ON c.id = a.customer_id

-- Показать список банковских аккаунтов,
-- у которых баланс не совпадает с суммой баланса по карточкам.
-- В отдельной колонке вывести разницу

SELECT DISTINCT a.id, a.balance, SUM(cc.balance) AS 'sum', a.balance - SUM(cc.balance) AS 'difference'
FROM Account AS a
	JOIN Credit_Card AS cc ON cc.account_id = a.id
GROUP BY a.id, a.balance
HAVING a.balance > SUM(cc.balance)

-- Вывести кол-во банковских карточек для каждого соц статуса (2 реализации, GROUP BY и подзапросом)

-- Group By

SELECT s.id AS status, COUNT(cc.credit_card_id) AS count
FROM Credit_Card AS cc
	JOIN Account AS a ON a.id = cc.account_id
	JOIN Customer AS c ON c.id = a.customer_id
	JOIN Status AS s ON s.id = c.status_id 
GROUP BY s.id

-- Inner Query

SELECT s.id, (SELECT COUNT(cc.credit_card_id) FROM Credit_Card AS cc
				JOIN Account AS a ON a.id = cc.account_id
				JOIN Customer AS c ON c.id = a.customer_id
			  WHERE s.id = c.status_id) 
FROM Status AS s


-- Написать stored procedure которая будет добавлять по 10$ на каждый банковский аккаунт
-- для определенного соц статуса. 
-- Входной параметр процедуры - Id социального статуса.

-- Обработать исключительные ситуации (например, был введен неверные номер соц. статуса.
-- Либо когда у этого статуса нет привязанных аккаунтов)

ALTER PROCEDURE [dbo].[AddMoney]
	@status_id int
AS
BEGIN
	 IF NOT EXISTS (SELECT id FROM Status WHERE id = @status_id)
	 PRINT 'No such status in the table'
	 ELSE IF NOT EXISTS(SELECT * FROM Customer WHERE status_id = @status_id)
	 PRINT 'No cards with this status'
	 ELSE
	 BEGIN
		UPDATE Account
		SET Account.balance = Account.balance + (10 * 2.55)
		FROM Customer, Status
		WHERE Account.customer_id = Customer.id AND Customer.status_id = @status_id
	 END;
END;

EXEC AddMoney '2'

-- Получить список доступных средств для каждого клиента. 
-- То есть если у клиента на банковском аккаунте 60 рублей, и у него 2 карточки по 15 рублей на каждой,
-- то у него доступно 30 рублей для перевода на любую из карт

SELECT c.id as Customer,
	   a.balance AS 'Account Balance', 
	   SUM (cc.balance) AS 'Cards Sum', 
	   (a.balance - SUM(cc.balance)) AS Available
FROM Customer AS c
	JOIN Account AS a ON a.customer_id = c.id
	JOIN Credit_Card AS cc ON cc.account_id = a.id
GROUP BY c.id, a.balance
HAVING a.balance - SUM(cc.balance) >= 0

-- Написать процедуру которая будет переводить определённую сумму со счёта на карту этого аккаунта.  
-- При этом будем считать что деньги на счёту все равно останутся, просто сумма средств на карте увеличится. 
-- Например, у меня есть аккаунт на котором 1000 рублей и две карты по 300 рублей на каждой. 
-- Я могу перевести 200 рублей на одну из карт, при этом баланс аккаунта останется 1000 рублей,
-- а на картах будут суммы 300 и 500 рублей соответственно. 
-- После этого я уже не смогу перевести 400 рублей с аккаунта ни на одну из карт, так как останется всего 200 свободных рублей (1000-300-500). 
-- Переводить БЕЗОПАСНО. То есть использовать транзакцию

ALTER PROCEDURE [dbo].[TransferMoney]
	@account_id int,
	@credit_card_id int,
	@transfer_money decimal(10, 2)
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM Account WHERE id = @account_id)
	PRINT 'No such account'
	ELSE IF NOT EXISTS (SELECT cc.credit_card_id FROM Credit_Card AS cc, Account AS a
						WHERE a.id = @account_id AND cc.account_id = a.id AND cc.credit_card_id = @credit_card_id)
	PRINT 'No such card in the account'
	ELSE IF NOT EXISTS (SELECT cc.account_id
						FROM Credit_Card AS cc, Account
						WHERE cc.account_id = @account_id
						GROUP BY Account.balance, cc.account_id
						HAVING Account.balance - SUM(cc.balance) > @transfer_money)
	PRINT 'Not enough money on the account'
	ELSE 
	BEGIN
		SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
		BEGIN TRANSACTION;
			UPDATE Credit_Card
			SET Credit_Card.balance = cc.balance + @transfer_money
			FROM Credit_Card AS cc
			WHERE cc.account_id = @account_id AND cc.credit_card_id = @credit_card_id
		COMMIT TRANSACTION;
	END;
END;

EXEC TransferMoney '1', '2', '10'

 -- Написать триггер на таблицы Account/Cards 
 -- чтобы нельзя была занести значения в поле баланс если это противоречит условиям  
 -- (то есть нельзя изменить значение в Account на меньшее, чем сумма балансов по всем карточкам.

UPDATE Account
SET balance = '2000'
WHERE id = '1'

CREATE TRIGGER Account_UPDATE
   ON [dbo].[Account]
   AFTER UPDATE
   AS
BEGIN
	DECLARE @balance decimal(10, 2);
	DECLARE @account_id int

	SELECT @account_id = Account.id FROM inserted Account
	SELECT @balance = Account.balance FROM inserted Account

	IF @balance < (SELECT SUM(cc.balance) AS sum
				   FROM Credit_Card as cc)
	BEGIN
		RAISERROR ('You can not update account balance with the value less than the summary of all cards connected to this account.', 16, 1);
		ROLLBACK TRANSACTION
	END
	ELSE
		PRINT 'done'
END

-- И соответственно нельзя изменить баланс карты если в итоге сумма на картах будет больше чем баланс аккаунта)

UPDATE Credit_Card
SET balance = '130'
WHERE credit_card_id = '1'

CREATE TRIGGER Card_UPDATE
ON [dbo].[Credit_Card]
AFTER UPDATE
AS
BEGIN
	DECLARE @card_balance decimal(10, 2)
	DECLARE @all_cards_balance decimal(10, 2)
	DECLARE @account_id int
	DECLARE @account_balance decimal(10, 2)

	SELECT @account_id = (SELECT account_id FROM deleted)
	SELECT @account_balance = (SELECT balance FROM Account
							   WHERE id = @account_id)
	SELECT @card_balance = (SELECT balance FROM inserted)
	SELECT @all_cards_balance = (SELECT SUM(balance) FROM Credit_Card
							     WHERE account_id = @account_id)
	
	IF @account_balance < @all_cards_balance
	BEGIN
		RAISERROR ('You can not update card balance with the value that makes the summary balance of all cards more than account balance', 16, 1);
		ROLLBACK TRANSACTION
	END
	ELSE
		PRINT 'done'
END
