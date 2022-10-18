-- Покажи мне список банков у которых есть филиалы в городе X

SELECT DISTINCT CONVERT(VARCHAR(MAX), Bank.name) FROM Bank
	JOIN Bank_Filial_City as bfc ON bfc.bank_id = Bank.id
	JOIN City ON bfc.city_id = City.id
WHERE City.name = 'Homiel'

-- Получить список карточек с указанием имени владельца, баланса и названия банка

SELECT acc.id, Credit_Card.balance, Customer.name, Bank.name
FROM Account_Credit_Card as acc
	JOIN Account ON acc.account_id = Account.id
	JOIN Credit_Card ON acc.credit_card_id = Credit_Card.id
	JOIN Customer ON Account.id = Customer.account_id
	JOIN Bank ON Account.bank_id = Bank.id

-- Показать список банковских аккаунтов у которых баланс не совпадает с суммой баланса по карточкам.
-- В отдельной колонке вывести разницу

SELECT DISTINCT Account.id as account,
	   Account.balance,
	   SUM(cc.balance) as sum,
	   (Account.balance - sum(cc.balance)) as difference
FROM Account_Credit_Card as acc
	JOIN Account ON acc.account_id = Account.id
	JOIN Credit_Card as cc ON acc.credit_card_id = cc.id
GROUP BY Account.id, Account.balance
HAVING Account.balance > sum(cc.balance)

-- Вывести кол-во банковских карточек для каждого соц статуса 

-- Group By

SELECT Status.id as 'status id', count(acc.credit_card_id) as cards 
FROM Account_Credit_Card as acc
	JOIN Account ON Account.id = acc.account_id
	JOIN Customer ON Customer.account_id = Account.id
	JOIN Status ON Status.Id = Customer.status_id
GROUP BY Status.id

-- Inner Query

SELECT Status.id as 'status id', 
(SELECT count(acc.credit_card_id) 
	FROM Account_Credit_Card as acc, Account, Customer
    WHERE Customer.status_id = Status.id AND
		  Customer.account_id = Account.id AND
	      Account.id = acc.account_id
) as cards 
FROM Status

-- Написать stored procedure которая будет добавлять по 10$ на каждый банковский аккаунт для определенного соц статуса 
-- Входной параметр процедуры - Id социального статуса.
-- Обработать исключительные ситуации (например, был введен неверные номер соц. статуса. Либо когда у этого статуса нет привязанных аккаунтов).

USE [Bank]
GO
/****** Object:  StoredProcedure [dbo].[AddMoney]    Script Date: 18.10.2022 13:24:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[AddMoney]
	@status_id int
AS
BEGIN
	 IF NOT EXISTS (SELECT id FROM Status WHERE id = @status_id)
	 PRINT 'No such status in the table'
	 ELSE IF NOT EXISTS(SELECT Account.id FROM Account
							JOIN Customer ON Customer.account_id = Account.id
						WHERE Customer.status_id = @status_id)
	 PRINT 'No cards with this status'
	 ELSE
	 BEGIN
		UPDATE Account
		SET Account.balance = Account.balance + (10 * 2.55)
		FROM Customer, Status
		WHERE Account.id = Customer.account_id AND Customer.status_id = @status_id
	 END;
END;


USE Bank
EXEC AddMoney 5

-- Получить список доступных средств для каждого клиента. 
-- То есть если у клиента на банковском аккаунте 60 рублей, 
-- и у него 2 карточки по 15 рублей на каждой, то у него доступно 30 рублей для перевода на любую из карт

SELECT Customer.id as Customer,
	   Account.balance AS 'Account Balance', 
	   SUM (cc.balance) AS 'Cards Sum', 
	   (Account.balance - SUM(cc.balance)) AS Available
FROM Customer
	JOIN Account ON Account.id = Customer.account_id
	JOIN Account_Credit_Card AS acc ON acc.account_id = Account.id
	JOIN Credit_Card AS cc ON cc.id = acc.credit_card_id
GROUP BY Customer.id, Account.balance
HAVING Account.balance - SUM(cc.balance) > 0

-- Написать процедуру которая будет переводить определённую сумму со счёта на карту этого аккаунта. 
-- При этом будем считать что деньги на счёту все равно останутся, просто сумма средств на карте увеличится. 
-- Например, у меня есть аккаунт на котором 1000 рублей и две карты по 300 рублей на каждой. 
-- Я могу перевести 200 рублей на одну из карт, при этом баланс аккаунта останется 1000 рублей, а на картах будут суммы 300 и 500 рублей соответственно. 
-- После этого я уже не смогу перевести 400 рублей с аккаунта ни на одну из карт, так как останется всего 200 свободных рублей (1000-300-500). 
-- Переводить БЕЗОПАСНО. То есть использовать транзакцию

USE [Bank]
GO
/****** Object:  StoredProcedure [dbo].[TransferMoney]    Script Date: 18.10.2022 13:26:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TransferMoney]
	@account_id int,
	@credit_card_id int,
	@transfer_money decimal(10, 2)
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM Account WHERE id = @account_id)
	PRINT 'No such account'
	ELSE IF NOT EXISTS (SELECT acc.credit_card_id FROM Account_Credit_Card AS acc, Account
						WHERE Account.id = @account_id AND acc.account_id = Account.id AND acc.credit_card_id = @credit_card_id)
	PRINT 'No such card in the account'
	ELSE IF NOT EXISTS (SELECT acc.account_id
						FROM Account_Credit_Card AS acc, Account, Credit_Card
						WHERE acc.account_id = @account_id AND Account.id = acc.account_id AND Credit_Card.id = acc.credit_card_id
						GROUP BY Account.balance, acc.account_id
						HAVING Account.balance - SUM(Credit_Card.balance) > @transfer_money)
	PRINT 'Not enough money on the account'
	ELSE 
	BEGIN
		SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
		BEGIN TRANSACTION;
			UPDATE Credit_Card
			SET Credit_Card.balance = Credit_Card.balance + @transfer_money
			FROM Account_Credit_Card AS acc
			WHERE acc.account_id = @account_id AND Credit_Card.id = acc.credit_card_id
		COMMIT TRANSACTION;
	END;
END;

USE Bank
EXEC TransferMoney 4, 100, 5

-- Написать триггер на таблицы Account/Cards чтобы нельзя была занести значения в поле баланс если это противоречит условиям  
-- (то есть нельзя изменить значение в Account на меньшее, чем сумма балансов по всем карточкам. 

USE [Bank]
GO
/****** Object:  Trigger [dbo].[Account_UPDATE]    Script Date: 18.10.2022 13:27:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[Account_UPDATE]
   ON [dbo].[Account]
   AFTER UPDATE
   AS
BEGIN
	DECLARE @balance decimal(10, 2);
	DECLARE @account_id int

	SELECT @account_id = Account.id FROM inserted Account
	SELECT @balance = Account.balance FROM inserted Account

	IF @balance < (SELECT SUM(cc.balance) AS sum
				   FROM Credit_Card as cc
						JOIN Account_Credit_Card as acc ON acc.account_id = @account_id
				   WHERE cc.id = acc.credit_card_id)
	BEGIN
		RAISERROR ('You can not update account balance with the value less than the summary of all cards connected to this account.', 16, 1);
		ROLLBACK TRANSACTION
	END
END

 UPDATE Account
 SET balance = '153.68'
 WHERE Account.id = '5'

--И соответственно нельзя изменить баланс карты если в итоге сумма на картах будет больше чем баланс аккаунта)

USE [Bank]
GO
/****** Object:  Trigger [dbo].[Card_UPDATE]    Script Date: 18.10.2022 13:28:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[Card_UPDATE]
ON [dbo].[Credit_Card]
AFTER UPDATE
AS
BEGIN
	DECLARE @card_id int
	DECLARE @money decimal(10, 2)
	DECLARE @account_id int
	DECLARE @account_balance decimal(10, 2)

	SELECT @card_id = Credit_Card.id FROM inserted Credit_Card
	SELECT @money = Credit_Card.balance FROM inserted Credit_Card
	SELECT @account_id = (SELECT acc.account_id FROM Account_Credit_Card as acc
						  WHERE acc.credit_card_id = @card_id)
	SELECT @account_balance = (SELECT balance
							   FROM Account
							   WHERE id = @account_id)

	IF (SELECT SUM(cc.balance) + @money - (SELECT Credit_Card.balance FROM Credit_Card WHERE Credit_Card.id = @card_id) AS sum
		FROM Credit_Card as cc
			JOIN Account_Credit_Card as acc ON acc.account_id = @account_id
		WHERE cc.id = acc.credit_card_id) > @account_balance
	BEGIN
		RAISERROR ('You can not update card balance with the value that makes the summary balance of all cards more than account balance', 16, 1);
		ROLLBACK TRANSACTION
	END
END

UPDATE Credit_Card
SET balance = '9000'
FROM Account
WHERE Credit_Card.id = '100'
