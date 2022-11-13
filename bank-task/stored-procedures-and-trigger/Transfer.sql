-- Написать процедуру которая будет переводить определённую сумму со счёта на карту этого аккаунта.  
-- При этом будем считать что деньги на счёту все равно останутся, просто сумма средств на карте увеличится. 
-- Например, у меня есть аккаунт на котором 1000 рублей и две карты по 300 рублей на каждой. 
-- Я могу перевести 200 рублей на одну из карт, при этом баланс аккаунта останется 1000 рублей,
-- а на картах будут суммы 300 и 500 рублей соответственно. 
-- После этого я уже не смогу перевести 400 рублей с аккаунта ни на одну из карт, так как останется всего 200 свободных рублей (1000-300-500). 
-- Переводить БЕЗОПАСНО. То есть использовать транзакцию

USE Bank
GO
CREATE PROCEDURE TransferMoney
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