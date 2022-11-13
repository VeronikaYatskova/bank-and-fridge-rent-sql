-- �������� ��������� ������� ����� ���������� ����������� ����� �� ����� �� ����� ����� ��������.  
-- ��� ���� ����� ������� ��� ������ �� ����� ��� ����� ���������, ������ ����� ������� �� ����� ����������. 
-- ��������, � ���� ���� ������� �� ������� 1000 ������ � ��� ����� �� 300 ������ �� ������. 
-- � ���� ��������� 200 ������ �� ���� �� ����, ��� ���� ������ �������� ��������� 1000 ������,
-- � �� ������ ����� ����� 300 � 500 ������ ��������������. 
-- ����� ����� � ��� �� ����� ��������� 400 ������ � �������� �� �� ���� �� ����, ��� ��� ��������� ����� 200 ��������� ������ (1000-300-500). 
-- ���������� ���������. �� ���� ������������ ����������

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