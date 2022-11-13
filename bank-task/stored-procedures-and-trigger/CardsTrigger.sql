USE Bank
GO
CREATE TRIGGER Card_UPDATE
ON Credit_Card
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
GO
