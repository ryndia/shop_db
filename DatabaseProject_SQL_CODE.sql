-------------------------------------------------DAITO OTAKU TOY SHOP DATABASE--------------------------------------------------------
  __________________________________________________________________________________________________________________________________

------------------------------------------------------CREATING TABLES-----------------------------------------------------------------
CREATE database Daito_toy_shop
  
CREATE TABLE employee
(
	empID INT IDENTITY PRIMARY KEY,
	empLname VARCHAR(20),
	empFname VARCHAR(20),
	empAdd VARCHAR(255),
	empContactNum VARCHAR(15),
	empMail VARCHAR(40) CHECK(empMail LIKE '%@%.%'),
	salary FLOAT CHECK(salary > 0),
	gender VARCHAR(1) CHECK(gender IN ('M','F','f','m')),
	dob DATETIME
);

CREATE TABLE customer
(
	custID INT IDENTITY(1,1) PRIMARY KEY,
	custFname VARCHAR(35) NOT NULL,
	custLname VARCHAR(35) NOT NULL,
	custAddress VARCHAR(255) NOT NULL,
	custContactNum VARCHAR(15),
	custMail VARCHAR(40) CHECK(custMail LIKE '%@%.%') NOT NULL unique
);

CREATE TABLE product
(
	productID INT IDENTITY PRIMARY KEY,
	prod_desc VARCHAR(255),
	stklvl INT CHECK(stklvl > -1),
	price FLOAT,--Dollar
	product_type VARCHAR(50),
	supplierID INT NOT NULL,
);

CREATE TABLE promocode
(
	pcode VARCHAR(20) primary key,
	deduction FLOAT CHECK(deduction < 1)
);

CREATE table supplier
(
	supID INT IDENTITY PRIMARY KEY,
	supName VARCHAR(35),
	supMail VARCHAR(30) CHECK(supMail LIKE '%@%.%') NOT NULL UNIQUE,
);

CREATE TABLE website
(
	loginID INT IDENTITY PRIMARY KEY,
	custID INT NOT NULL,
	LoginName VARCHAR(35) NOT NULL,
	loginPassword VARCHAR(20) NOT NULL
);

CREATE TABLE cart
(
	cartId INT IDENTITY PRIMARY KEY,
	custId INT NOT NULL,
	last_edit_date DATETIME NOT NULL,
	shippingID INT,
	promocode VARCHAR(20) NULL
);


CREATE TABLE cart_item
(
	cartID INT,
	productID INT,
	Qty INT check(Qty > 0),
	primary key(cartID, productID)
);

CREATE TABLE payment
(
	paymentId INT IDENTITY PRIMARY KEY,
	paydate datetime NOT NULL,
	pay_Des VARCHAR(30),
	total_Amount FLOAT CHECK(total_Amount > 0) NOT NULL,
	cartID INT NOT NULL,
);

CREATE TABLE shipping
(
	shippingID INT IDENTITY PRIMARY KEY,
	shiptype VARCHAR(20),
	deliveryTime INT,
	fee FLOAT
);

CREATE TABLE tracking
(
	trackingNo INT IDENTITY PRIMARY KEY,
	shippingID INT NOT NULL,
	paymentID INT NOT NULL
);

ALTER TABLE cart 
ADD FOREIGN KEY (custId) REFERENCES customer(custID)
ALTER TABLE cart 
ADD FOREIGN KEY (shippingID) REFERENCES shipping(shippingID)
ALTER TABLE cart 
add foreign key (promocode) REFERENCES promocode(pcode)

ALTER TABLE product 
ADD FOREIGN KEY (supplierID) REFERENCES supplier(supID)

ALTER TABLE cart_item
ADD FOREIGN KEY (cartID) REFERENCES cart(cartID)
ALTER TABLE cart_item
ADD FOREIGN KEY (productID) REFERENCES product(productID)

ALTER TABLE website
ADD FOREIGN KEY (custID) REFERENCES customer(custID)

ALTER TABLE Emp_contact_supplier
ADD FOREIGN KEY (productID) REFERENCES product(productID)

ALTER TABLE payment 
ADD FOREIGN KEY (cartID) REFERENCES cart(cartID)

ALTER TABLE tracking
ADD FOREIGN KEY (shippingID) REFERENCES shipping(shippingID)
ALTER TABLE tracking
ADD FOREIGN KEY (paymentID) REFERENCES payment(paymentID)

--------------------------------------------------------------------------------------------------------------------------------------
--Insert Stored Procedures

--1

ALTER PROCEDURE sp_customer_insert 
@cust_fname varchar(35), @cust_lname varchar(35), @cust_add varchar(255), @cust_contact_num varchar(15),
@cust_mail varchar(40), @loginname varchar(35) = NULL, @loginpassword varchar(20) = NULL
AS 
BEGIN 

	DECLARE @id integer
	set @id = -1
	BEGIN TRY
		INSERT INTO customer(custFname, custLname, custAddress, custContactNum,custMail) VALUES (@cust_fname, @cust_lname,
		@cust_add, @cust_contact_num,@cust_mail)
		
		IF @loginname is not NULL and @loginpassword is not NULL
		BEGIN 
			SELECT @id = MAX(custID)
			FROM customer c
		END
		
		IF @id <> -1
		begin
			if not exists(select * from website w where custID = @id)
				BEGIN
					INSERT INTO website(custID,LoginName,loginPassword) VALUES (@id, @loginname, @loginpassword)
					PRINT 'Login details registered successfully !'
				END;
			ELSE
				BEGIN
					PRINT 'Customer already have an account, please login to your account'
				END;
		end
		
		if @id = -1
		begin
			print 'Visited Customer: details saved !'
		end
		
	END TRY

	BEGIN CATCH
		PRINT 'Error Input'
	END CATCH
	
END

sp_customer_insert 'Gon', 'Uchiha','Flacq','794566133','GonAdie@tmail.com'
sp_customer_insert 'Adams', 'Bryan', 'Curepipe', '7412588962', 'AdamB20@dogomail.com'
sp_customer_insert 'Jame', 'Donn', 'Curepipe', '745412574685', 'JDonn@dogomail.com'
sp_customer_insert 'Franc', 'Frederic', 'Rose Hill', '7412535223', 'Franc19999@dogemail.com','franc19','87654321'

select *
from customer
select * 
from website w2 
--2

ALTER PROCEDURE sp_insert_supplier @sup_name VARCHAR(35),@s_mail VARCHAR(30)
AS
BEGIN
	BEGIN TRY
		INSERT INTO supplier(supName,supMail) VALUES(@sup_name,@s_mail)
	END TRY

	BEGIN CATCH
		PRINT 'Error input !'
	END CATCH
END

sp_insert_supplier 'gintama store','Ginta@info.com'	

select *
from supplier s 

--3
CREATE PROCEDURE sp_insert_promocode @code VARCHAR(20),@reduce FLOAT AS
BEGIN
	BEGIN TRY
		INSERT INTO promocode (pcode,deduction) VALUES(@code,@reduce)
		PRINT 'New promocode added succesfully !'
	END TRY

	BEGIN CATCH
		PRINT 'Error input !'
	END CATCH
END
select * from promocode p 
sp_insert_promocode 'QWERTY2000',0.25
sp_insert_promocode 'ASDFG2000' ,0.75

--4
ALTER PROCEDURE sp_insert_employee @emp_fname varchar(35), @emp_last varchar(35), @emp_add varchar(255), @emp_contact varchar(15),
@emp_mail varchar(40) = NULL, @emp_salary float = null, @emp_sex varchar(1) = null, @dob datetime = null 
AS 
BEGIN 
	DECLARE @id INTEGER

	BEGIN TRY
		INSERT INTO employee(empFname, empLname, empAdd, empContactNum, empMail,salary,gender,dob)
		VALUES(@emp_fname, @emp_last, @emp_add, @emp_contact, @emp_mail, @emp_salary, @emp_sex, @dob);
	END TRY

	BEGIN CATCH
		PRINT 'Error input !'
	END catch
END

sp_insert_employee 'Akshit', 'Tooshalduth', 'QuatreBornes', '57890678', 'at@gmail.com', 15000, 'M', '2001-06-11'
sp_insert_employee 'John', 'Bener', 'QuatreBornes', '74185296', 'JB@gmail.com', 15000, 'M', '2001-08-11'

select *
from employee e 

--5
CREATE Procedure sp_insert_shipping @ship_type VARCHAR(20), @ship_dt INT, @ship_cost FLOAT AS -- dt: delivery time
BEGIN
	BEGIN TRY
		INSERT INTO shipping(shiptype,deliveryTime ,fee)
		VALUES(@ship_type, @ship_dt, @ship_cost)

		PRINT 'Shpping method insert successfully !'
	END TRY

	BEGIN CATCH
		PRINT 'Error input !'
	END CATCH
END

sp_insert_shipping 'Express Airline', 2, 135.75

select *
from shipping

--6
ALTER PROCEDURE sp_insert_product @prod_desc VARCHAR(255), @stk_lvl INT, @cost FLOAT, @type VARCHAR(50),@sup_ID INT --stk_lvl : Stock Level
AS
BEGIN
	DECLARE @id INT
	SET @id = @sup_ID
	IF NOT EXISTS (SELECT supID
				   FROM supplier s
				   WHERE @id = supID)
		BEGIN 
			PRINT 'Supplier ID not found !'
			RETURN
		END

	BEGIN TRY
		INSERT INTO product(prod_Desc,stklvl,price,product_type,supplierID)
		VALUES (@prod_desc, @stk_lvl, @cost, @type, @sup_ID)

	END TRY

	BEGIN CATCH
		PRINT 'Error input !'
	END CATCH
END

sp_insert_product 'Jujutsu', 40, 5.95, 'Statue', 2
sp_insert_product 'Tokyo Ghoul', 100, 16.95, 'Statue', 3
select *
from counttable_products 

--7
CREATE PROCEDURE sp_insert_user @cust_id INT,@login_name VARCHAR(35),@login_code VARCHAR(20)
AS
BEGIN
	DECLARE @id INT
	SET @id = @cust_id
	
	if EXISTS (select * from customer c2 where c2.custID = @id)
	BEGIN 
		print 'account alrealdy exist for this customer, please login'
		RETURN 
	END

	IF NOT EXISTS(SELECT custID
				  FROM customer c
				  WHERE @id = c.custID)
	BEGIN 
		PRINT 'Error Customer Identification !'
		RETURN 
	END 

	BEGIN TRY
		INSERT INTO website(custID,LoginName,loginPassword) VALUES (@cust_id, @login_name, @login_code)
		print 'New user added successfully !'
	END TRY

	BEGIN CATCH
		PRINT 'Error input !'
	END CATCH
END

sp_insert_user 6,'KateV','PAsssforwd'

--8#
ALTER PROCEDURE sp_insert_cart @custID INT,@ship_ID INT, @promo_code VARCHAR(20) = NULL
AS
BEGIN
	IF NOT EXISTS (SELECT c.custID,s.shippingID
				   FROM customer c, shipping s
				   WHERE c.custID = @custID
				   AND s.shippingID = @ship_ID)
	BEGIN 
		PRINT 'Cart cannot be registered !'
		RETURN 
	END
	
	DECLARE @d DATETIME
	SET @d = GETDATE() 

	BEGIN TRY
		INSERT INTO cart(custId, last_edit_date, shippingID, promocode) values(@custID, @d,@ship_ID, @promo_code)
	END TRY

	BEGIN CATCH
		SELECT
          ERROR_NUMBER() AS ErrorNumber,
          ERROR_SEVERITY() AS ErrorSeverity,
          ERROR_STATE() AS ErrorState,
          ERROR_PROCEDURE() AS ErrorProcedure,
          ERROR_LINE() AS ErrorLine,
          ERROR_MESSAGE() AS ErrorMessage
      PRINT ERROR_MESSAGE()
    END CATCH
END

sp_insert_cart 2, 1, 'QWERTY2000'

--9
ALTER PROCEDURE sp_insert_payment @pay_Desc VARCHAR(30),@cartID INTEGER AS
BEGIN
	IF EXISTS(SELECT *
		      FROM payment p
			  WHERE @cartID = p.cartId)
		BEGIN 
			print 'Cart already paid !'	
			return
		END

	DECLARE @totalfee FLOAT

	SET @totalfee  = (SELECT SUM (Qty * price)
					  FROM cart_item ct, product p
					  WHERE ct.cartID = @cartID
					  AND ct.productID = p.productID)

	DECLARE @d FLOAT -- d: deduction_price
	SET @d = (SELECT deduction
			  FROM promocode p, cart c
			  WHERE p.pcode = c.promocode and c.cartId = @cartID)

	IF @d IS NOT NULL
		BEGIN 
			SET @d = 1 - @d
			SET @totalfee = @d * @totalfee
		END 

	DECLARE @shipFee FLOAT

	SET @shipFee = (SELECT fee
					FROM cart c,shipping s
					where c.cartID = @cartID
					AND c.shippingID = s.shippingID)

	SET @totalfee = @totalfee + @shipFee

	BEGIN TRY
		INSERT INTO payment
		VALUES(getdate(), @pay_Desc, @totalfee, @cartID)
	END TRY

BEGIN CATCH
		SELECT
          ERROR_NUMBER() AS ErrorNumber,
          ERROR_SEVERITY() AS ErrorSeverity,
          ERROR_STATE() AS ErrorState,
          ERROR_PROCEDURE() AS ErrorProcedure,
          ERROR_LINE() AS ErrorLine,
          ERROR_MESSAGE() AS ErrorMessage
      PRINT ERROR_MESSAGE()
    END CATCH
END

sp_insert_payment 'CASH', 6

select *
from payment p 

select *
from product p 

select *
from cart_item ci 


--11
CREATE PROCEDURE sp_insert_tracking @pay_ID INT, @ship_ID INT AS
BEGIN
	IF NOT EXISTS(SELECT *
				  FROM payment
				  WHERE paymentID  = @pay_ID)
		BEGIN 
			PRINT 'Payment ID does not exist !'
			RETURN
		END
	IF NOT EXISTS(SELECT *
				  FROM shipping
				  WHERE shippingID = @ship_ID)
		BEGIN 
			print 'Shipping ID does not exist !'
		END
	BEGIN TRY
		INSERT INTO tracking
		VALUES(@ship_ID,@pay_ID)

		PRINT 'New tracking ID assigned succesfully !'
	END TRY
	BEGIN CATCH
		PRINT 'Error input !'
	END CATCH
END

sp_insert_tracking 1, 1

--12
ALTER PROCEDURE sp_insert_cartItem @prod_id INT, @cart_ID INT, @Qty INT AS
BEGIN 	
	IF NOT EXISTS (SELECT productID, cartID
					FROM product p, cart c
					WHERE @prod_id = p.productID
					AND @cart_ID = c.cartId)
	BEGIN 
	 	PRINT 'Input error !'
	 	RETURN 
	END 
	 DECLARE @stk INT
	 SET @stk = (SELECT stklvl
				 FROM product p1
				 WHERE p1.productID = @prod_id)
	 IF @stk < @Qty
		 BEGIN 
	 		PRINT 'Not enough in stock !'
	 		RETURN 
		 END 

	BEGIN TRY
		INSERT INTO cart_item(cartID, productID, Qty)
		VALUES(@cart_ID,@prod_id, @Qty)
		PRINT 'New item added to cart !'
	END TRY

		BEGIN CATCH
		SELECT
          ERROR_NUMBER() AS ErrorNumber,
          ERROR_SEVERITY() AS ErrorSeverity,
          ERROR_STATE() AS ErrorState,
          ERROR_PROCEDURE() AS ErrorProcedure,
          ERROR_LINE() AS ErrorLine,
          ERROR_MESSAGE() AS ErrorMessage
      PRINT ERROR_MESSAGE()
    END CATCH
END

sp_insert_cartItem 1, 6, 2
sp_insert_cartItem 3, 6, 3


sp_

select *
from cart_item ci 

--------------------------------------------------Other Stored Procedures---------------------------------------------------------

--1
CREATE PROCEDURE sp_productQty_totalprice AS --Total price of products for whole stock
BEGIN
	SELECT productID, SUM(price * stklvl) AS TOTAL_PRICE
	FROM product
	GROUP BY productID
END;

EXEC sp_productQty_totalprice;

--2
CREATE PROCEDURE sp_productQty_totalprice_specific_item @id INT AS --Total price of a specific product for whole stock
BEGIN
	SELECT SUM(price * stklvl) AS Total_Price 
	FROM product
	WHERE productID = @id
END;

EXEC sp_productQty_totalprice_specific_item 4;

--3
CREATE PROCEDURE sp_chart_total_cost @cID INT AS --total cost in carts
BEGIN
	SELECT cartID, SUM(Qty * p.price) AS Total_Cost
	FROM product p, cart_item c
	WHERE cartID = @cID
	AND c.productID = p.productID
	GROUP BY c.cartID
END;

EXEC sp_chart_total_cost 4;

--4 
CREATE PROCEDURE sp_check_paid AS --Display all that have paid

BEGIN
	SELECT c.cartID AS Paid_cart
	FROM payment p, cart c
	WHERE p.cartID = c.cartID
END;

EXEC sp_check_paid;

--5
CREATE PROCEDURE sp_price_range @low FLOAT = NULL ,@high FLOAT = NULL
AS
BEGIN
	SELECT productID, prod_desc, price
	FROM product
	WHERE price >= @low AND price <= @high
	ORDER BY price
END

EXEC sp_price_range 0,30

--6
CREATE PROCEDURE sp_check_active_cart AS --check if a cart is active
BEGIN
	SELECT *
	FROM cart
	WHERE GETDATE() - last_edit_date < 14
		--clean cart table of inactive cart
	DELETE FROM cart
	WHERE 	GETDATE() - last_edit_date > 14
	AND cartID NOT IN (SELECT cartID
						FROM payment)
END;

EXEC sp_check_active_cart;

--7
CREATE PROCEDURE sp_stock_price AS--unit price of products
BEGIN
	SELECT productID, price
	FROM product
END;

EXEC sp_stock_price;

--8
CREATE PROCEDURE sp_in_shop_deliver AS--check which transaction will be taken at the shop
BEGIN
	SELECT *
	FROM shipping
	WHERE fee <= 0
END;

EXEC sp_in_shop_deliver 

--9
CREATE PROCEDURE sp_check_need_to_ship
AS
BEGIN
	SELECT paymentID
	FROM payment
	EXCEPT
	SELECT p.paymentID
	FROM payment p, tracking t
	WHERE p.paymentID = t.paymentID
END

EXEC sp_check_need_to_ship 

--10
CREATE PROCEDURE sp_highest_sale
AS
BEGIN
	SELECT MAX(total_Amount) AS 'Best_Sale $', paydate, c.productID, pr.prod_desc
	FROM product pr, payment pa, cart_item c
	WHERE pa.cartID = c.cartid
	AND c.productID = pr.productID
	GROUP BY paymentid, paydate, c.productID, pr.prod_desc
END

EXEC sp_highest_sale

--11
CREATE PROCEDURE sp_stock_price_specific @pid INT AS--unit price of specific product
BEGIN
	SELECT productID, price
	FROM product
	WHERE productID = @pid
END;

EXEC sp_stock_price_specific 2;

--12*************************************************************************
CREATE PROC sp_del_cust @CID INT
AS 
BEGIN
	BEGIN TRY
		DELETE FROM website 
		WHERE custID =  @CID --depends on where customerID is
		DELETE FROM customer 
		WHERE custID = @CID
	END TRY
	
	BEGIN CATCH
			PRINT 'Error !'
	END CATCH
END

sp_del_cust 8

--14
CREATE PROC sp_checks_if_exist
@emp INT = NULL, @cust INT = NULL, @sup INT = NULL, @prod INT = NULL
AS
BEGIN
	BEGIN TRY

	IF NOT EXISTS (SELECT *
						FROM employee
						WHERE @emp = empID)
		BEGIN
		PRINT 'Employee ' + CAST(@emp AS VARCHAR(5)) + ' not found !';
		END	

		ELSE
			PRINT 'Employee ' + CAST(@emp AS VARCHAR(5)) + ' found !';

		IF NOT EXISTS (SELECT *
						FROM customer
						WHERE @cust = custID)
		BEGIN
		PRINT 'Customer ' + CAST(@cust AS VARCHAR(5)) + ' not found !';
		END	

		ELSE
			PRINT 'Customer ' + CAST(@cust AS VARCHAR(5)) + ' found !';

		IF NOT EXISTS (SELECT *
						FROM supplier
						WHERE @sup = supID)
		BEGIN
		PRINT 'Supplier ' + CAST(@sup AS VARCHAR(5)) + ' not found !';
		END	

		ELSE
			PRINT 'Supplier ' + CAST(@sup AS VARCHAR(5)) + ' found !';

		IF NOT EXISTS (SELECT *
						FROM product
						WHERE @prod = productID)
		BEGIN
		PRINT 'Product ' + CAST(@prod AS VARCHAR(5)) + ' not found !';
		END	

		ELSE
			PRINT 'Product ' + CAST(@prod AS VARCHAR(5)) + ' found !';

	END TRY
	BEGIN CATCH
		SELECT
          ERROR_NUMBER() AS ErrorNumber,
          ERROR_SEVERITY() AS ErrorSeverity,
          ERROR_STATE() AS ErrorState,
          ERROR_PROCEDURE() AS ErrorProcedure,
          ERROR_LINE() AS ErrorLine,
          ERROR_MESSAGE() AS ErrorMessage
      PRINT ERROR_MESSAGE()
    END CATCH
  END		

 sp_checks_if_exist 6,4,2,NULL
------------------------------------------------------Triggers------------------------------------------------------------------------

-- 1
ALTER TRIGGER tg_check_customer --check if customer is already added or not
ON customer
INSTEAD OF INSERT
AS
BEGIN
	IF EXISTS (SELECT c.custMail
				FROM INSERTED i, customer c
				WHERE i.custMail = c.custMail)
		BEGIN
			PRINT 'Mail already in use, retry another or login !'
			RETURN 
		END
	
	declare @cF VARCHAR(35)
	declare @cL VARCHAR(35) 
	declare @cA VARCHAR(255) 
	declare @cCo VARCHAR(15)
	declare @cM VARCHAR(40)
	
	set @cF = (select custFname from inserted)
	set @cl = (select custLname from inserted)
	set @cA = (select custAddress from inserted)
	set @cCo = (select custContactNum from inserted)
	set @cM = (select custMail from inserted)
	
	if(select count(custID) from customer) = 0
	begin
		insert into customer(custID, custFname, custLname,custAddress,custContactNum,custMail) select * from inserted
	end
	else
	begin
		declare @cid integer
		set @cid = (select MAX(custID)+1 from customer c)
		set IDENTITY_INSERT customer ON 
		insert into customer(custID, custFname, custLname,custAddress,custContactNum,custMail) values(@cid,@cF,@cl,@cA,@cCo,@cM)
		set IDENTITY_INSERT customer OFF
	end
	PRINT 'New customer registered successfully !'
END;

-- 2
ALTER TRIGGER tg_check_email --check email validity
ON employee
INSTEAD OF INSERT
AS
BEGIN	
	declare @ei integer
	declare @el VARCHAR(20)
	declare @ef VARCHAR(20)
	declare @ea VARCHAR(255)
	declare @eC VARCHAR(15)
	declare @s FLOAT
	declare @g VARCHAR(1)
	declare @dob DATETIME
	DECLARE @mail AS VARCHAR(30)
	
	set @ei = (select MAX(empID) + 1  from employee e)
	set @el = (select empLname from inserted)
	set @ef = (select empFname from inserted)
	set @ea = (select empAdd from inserted)
	set @eC = (select empContactNum from inserted)
	set @s = (select salary from inserted)
	set @g = (select gender from inserted)
	set @dob = (select dob from inserted)

	
	SET @mail = (SELECT empMail FROM INSERTED)
	IF @mail not LIKE '%@%.' and EXISTS(select * from inserted i,employee e where e.empMail = i.empMail)
		BEGIN
			PRINT 'Invalid email.'
			RETURN
		END
	if @ei = null
	begin
		set @ei = 0
	end
	set IDENTITY_INSERT employee on
	insert into employee(empID,empFname, empLname, empAdd, empContactNum, empMail,salary,gender,dob) values(@ei,@el,@ef,@ea,@eC,@mail,@s,@g,@dob)
	set IDENTITY_INSERT employee off
	PRINT 'New employee saved successfully !'
END;

-- 3

ALTER TRIGGER tg_check_product --check if product is already added or not
ON product
INSTEAD OF INSERT
AS
BEGIN	
	DECLARE @quantityinstock INT
	SET @quantityinstock = (SELECT stklvl FROM inserted)
	DECLARE @prodid INT
	SET @prodid = (SELECT MAX(productID) + 1 FROM product p)
	declare @d varchar(255)
	declare @t varchar(50)
	declare @s integer
	declare @p float
	set @p = (select price from inserted)
	set @d = (select prod_desc from inserted)
	set @t = (select product_type from inserted)
	set @s = (select supplierID from inserted)
	
	if @prodid = null
	begin
		set @prodid = 0
	end
		
	IF EXISTS (SELECT * FROM INSERTED i, product p WHERE i.prod_desc = p.prod_desc)
		BEGIN
			PRINT 'Product already exists !'
			UPDATE product 
			SET stklvl = stklvl + @quantityinstock
			WHERE @d = prod_desc
		END
	ELSE 
		BEGIN 
			set IDENTITY_INSERT product on
			insert into product(ProductID, prod_desc,stklvl,price,product_type,supplierID) values (@prodid,@d,@quantityinstock,@p,@t,@s)
			set IDENTITY_INSERT product off
			PRINT 'Product insert successfully !'
		END
END;

-- 4
CREATE TRIGGER tg_increase_count_products --increment product count
ON product
AFTER INSERT
AS
BEGIN
	UPDATE counttable_products
	SET Number_of_Products = Number_of_Products + 1;
END;

CREATE TABLE counttable_products
( 
	Number_of_Products INT 
);
INSERT INTO counttable_products VALUES(0)

--5
CREATE TRIGGER tg_check_supplier--check if supplier is already added or not
ON supplier
INSTEAD OF INSERT
AS
BEGIN
	IF EXISTS (SELECT *
			   FROM INSERTED i, supplier s
			   WHERE i.supName = s.supName)
		BEGIN
			PRINT 'Supplier already exists.'
			RETURN
		END
		declare @supID integer
		declare @supMail varchar(30)
		declare @supName varchar(36)
		set @supID = (select max(supID) from supplier)
		set @supMail = (select supMail from INSERTED)
		set @supName= (select supName from INSERTED)
		if @supID = null
		begin
			set @supID = 0
		end
		set IDENTITY_INSERT supplier on
		insert into supplier(supID,supName,supMail) values(@supID,@supName,@supMail)
		set IDENTITY_INSERT supplier OFF 
		PRINT 'New supplier added successfully !'
END;

--6
CREATE TRIGGER tg_disp_prod_details 
ON product
AFTER INSERT
AS
BEGIN
	DECLARE @id AS INTEGER;
	DECLARE @description AS VARCHAR(20);
	DECLARE @stklvl AS INT;
	DECLARE @type AS VARCHAR(20);
	DECLARE @supplier AS VARCHAR(5);

	SET @id = (SELECT productID FROM inserted);
	SET @description = (SELECT prod_desc FROM inserted);
	SET @stklvl = (SELECT stklvl FROM inserted);
	SET @type = (SELECT product_type FROM inserted);
	SET @supplier = (SELECT supplierID FROM inserted);

	PRINT 'New product ' + @description ;
END;

--7
CREATE TRIGGER tg_store_old_data
ON product
AFTER UPDATE
AS
BEGIN
	DECLARE @old_price AS REAL;

	SET @old_price = (SELECT price FROM DELETED);

	INSERT INTO price_audit_product (ID, ProdDesc, old_price, new_price)
		SELECT productID, prod_desc, @old_price, price FROM INSERTED
END;

CREATE TABLE price_audit_product
(
	ID INTEGER PRIMARY KEY,
	ProdDesc VARCHAR(30) NOT NULL,
	old_price REAL,
	new_price REAL,
);

UPDATE product
SET price = 99.99
WHERE productID = 4

SELECT *
FROM product
select *
from price_audit_product

--8
CREATE TRIGGER tg_old_products
ON product
AFTER DELETE
AS
BEGIN
	IF @@ROWCOUNT = 0
		RETURN
	
	DECLARE @id AS INTEGER;
	DECLARE @desc AS VARCHAR(40);

	SET @id = (SELECT productID FROM DELETED);
	SET @desc = (SELECT prod_desc FROM DELETED);
	
	INSERT INTO products_not_in_sale_anymore  VALUES(@id, @desc, GETDATE());

END;

CREATE TABLE products_not_in_sale_anymore
(
	pid INTEGER NOT NULL,
	pdesc VARCHAR(40),
	date_deleted DATETIME,
	CONSTRAINT book_old_pkey PRIMARY KEY(pid, date_deleted),
	CONSTRAINT date_dlt_isbn_key UNIQUE(pdesc)
);

SELECT * FROM products_not_in_sale_anymore

DELETE FROM product
WHERE productID = 11

--9
ALTER TRIGGER tg_updte_stk
ON payment
AFTER INSERT 
AS 
BEGIN
	UPDATE product 
	SET stklvl = stklvl - Qty
	FROM cart_item, inserted i
	WHERE cart_item.cartID = i.cartID
	AND product.productID = cart_item.productID 
	declare @cart integer
	set	@cart = (select cartID from inserted)
	
	delete from cart_item 
	where productID in(
	select ci.productID 
	from cart_item ci, product p 
	WHERE ci.productID in (
							select productID
							from cart_item ci, inserted i
							where i.cartID = ci.cartID)
	and p.stklvl < ci.Qty)
	and cartID <> @cart
	
END

-- 10
CREATE TRIGGER tg_count_customer
ON customer
AFTER INSERT
AS
BEGIN
	UPDATE count_cust
	SET num_of_customer = num_of_customer + 1;
END;

CREATE TABLE count_cust
( 
	num_of_customer INT 
);

INSERT INTO count_cust VALUES(0)

--11

ALTER TRIGGER tg_check_cart
ON cart
INSTEAD OF INSERT 
AS 
BEGIN
	declare @CID integer
	set @CID = NULL 
	declare @cusID integer
	declare @lt DATETIME
	declare @s integer
	declare @p varchar(20)
	set @cusID = (select custId from inserted)
	set @lt = (select last_edit_date from inserted)
	set @s = (select shippingID from inserted)
	set @p = (select promocode from inserted)
	set @CID = (SELECT c.cartId
				FROM cart c, inserted i
				WHERE c.custId = i.custId
				EXCEPT
				SELECT c.cartId
				FROM cart c,payment p,inserted i
				WHERE i.custID = c.custId
				AND c.cartId = p.cartid)
				
	IF @cid is not NULL 
		BEGIN 
			PRINT 'Customer already have a cart, a new cart will be create after payment of current assigned cart !'
			RETURN
		END
	declare @cart integer
	set @Cart = (select MAX(cartid) + 1 from cart c)
	
	if @cart is null
		begin
			set @cart = 0
		end
	
	set IDENTITY_INSERT cart ON
	insert into cart(cartid, custId, last_edit_date, shippingID,promocode) values(@cart,@cusID,@lt,@s,@p)
	PRINT 'New cart added successfully !'
	set IDENTITY_INSERT cart OFF
	
END;

--12
CREATE TRIGGER tg_check_cart_payment
ON cart_item
INSTEAD OF INSERT 
AS 
BEGIN 
	IF EXISTS (SELECT *
				FROM payment p, INSERTED i
				WHERE p.cartID  = i.cartID)
	BEGIN 
		PRINT 'Customer has already paid for this cart !'
		PRINT 'Assign a new cart for customer !'
		PRINT 'Default shipping is used, change it later !'
		PRINT 'Promocode already used ! - Use a new promocode !'

		DECLARE @cust_id INT

		SET @cust_id = (SELECT cu.custID
						FROM customer cu, cart ca, INSERTED i
						WHERE ca.cartID = i.cartID 
						AND ca.custID = cu.custID)

		DECLARE @shipment_id INT

		SET @shipment_id = (SELECT shippingID 
							FROM cart ca, INSERTED i
							WHERE ca.cartID = i.cartID)
		
		INSERT INTO cart VALUES (@cust_id,GETDATE(), @shipment_id,'QWERTY2000')
		
		DECLARE @cart_id INT

		SET @cart_id = (SELECT MAX(cartID) FROM cart)

		DECLARE @qty INT
		DECLARE @prod_id INT
		
		SET @qty = (SELECT Qty
					FROM INSERTED)
		SET @prod_id = (SELECT productID
					FROM INSERTED)
		
		INSERT INTO cart_item VALUES (@cart_id, @prod_id, @qty) 
	END

	ELSE 

		BEGIN 
			INSERT INTO cart_item SELECT *
									FROM INSERTED
		END
	RETURN 
END

--13
CREATE TRIGGER tg_update_last_Edit
ON cart_item
AFTER insert
AS 
BEGIN 
	UPDATE cart
	SET last_edit_date = GETDATE() 
	FROM INSERTED i,cart c
	WHERE c.cartID = i.cartID
END

sp_insert_cartItem 3,3,1

------------------------------------------------------Populating Tables-------------------------------------------------------------
--Employees
--sp_insert_employee empID, empLname, empFname, empAdd, empContactNum, empMail, salary, gender, dob
sp_insert_employee 'Mounish','Bholah','PlainesDesRoches','57941996','mkbq@email.com',12000,'M','2001-09-16'
sp_insert_employee 'Akshit', 'Tooshalduth', 'QuatreBornes', '57890678', 'at@gmail.com', 15000, 'M', '2001-06-11'
sp_insert_employee 'Sarvesh', 'Dindyal', 'Curepipe', '57894678', 'srjd@gmail.com', 20000, 'M', '2001-02-16'

--Customers
--sp_customer_insert custId, custFname, custLname, custAddress, custContactNum, custMail
sp_customer_insert 'Ben', 'Seth','Maehbourg','65685236968','Ben10@tmail.com','ben11','Superalienk2000'
sp_customer_insert 'Adarsh', 'Mungra', 'Flacq', '57886644', 'admung@hotmail.com', 'ad69', 'AdArShM2006'
sp_customer_insert 'Shaheel', 'Gopal', 'RoseHill', '57893421', 'sg@gmail.com', 'sg444', 'Gopu'
sp_customer_insert 'Tom', '', 'andJerry', '57993421', 'taj@gmail.com', 'tag320', 'haha'
sp_customer_insert 'James', 'Burten','Rose Belle', '789845456','jb@tacomail.com'


--Products
--sp_insert_product productID, prod_desc, stklvl, price, product_type, supplierID
sp_insert_product 'Naruto Sage Mode', 40, 5.95, 'Giant Statue', 1
sp_insert_product 'Luffy Gear 4', 10, 25.00, 'Action Figure Super Posable', 1
sp_insert_product 'Goku Super Saiyan 3', 3, 100, 'Big Figure', 2
sp_insert_product 'Ichigo', 20, 3.33, 'Figurine', 2
sp_insert_product 'Monkey D.Luffy figure',35,15.95,'Giant Statue',3
INSERT INTO product VALUES('Itachi', 12, 6.99, 'Toy', 1)
INSERT INTO product VALUES('Jotaro', 22, 7.99, 'Action Sfigure', 2)
INSERT INTO product VALUES('Deku', 8, 4.99, 'Playable Toy', 3)
INSERT INTO product VALUES('Ash', 8, 15.99, 'Play Set', 3)
INSERT INTO product VALUES('Yu-Gi', 9, 9.99, 'Statue', 1)
INSERT INTO product VALUES('IronMan', 2, 2.99, 'Children Toy', 1)

--Cart
--sp_insert_cart cartID, shippingID, pcode
sp_insert_cart 1, 1, ASDFG2001
sp_insert_cart 1, 1, 'QWERTY2000'
sp_insert_cart 4, 2, QWERTY2000
sp_insert_cart 5, 3, NOBUENO

--Cart Details
--sp_insert_cartItem cartID, productID, Qty
sp_insert_cartItem 2, 2, 1
sp_insert_cartItem 3, 4, 2
sp_insert_cartItem 4, 3, 1
sp_insert_cartItem 5, 5, 1

--Shipping Details
--sp_insert_shipping shiptype, deliveryTime, fee
sp_insert_shipping 'Express Line', 3, 35.75
sp_insert_shipping 'Transport Direct', 2, 41.55
sp_insert_shipping 'In shop delivery', 0, 0
sp_insert_shipping 'Cargo',14,3.5

--Tracking
--sp_insert_tracking paymentID, shippingID
sp_insert_tracking 1, 1
sp_insert_tracking 2, 2

--Who contacted which supplier for which products
--sp_insert_emp_contact empID, supID, productID
sp_insert_emp_contact 2, 1, 2
sp_insert_emp_contact 2, 1, 3
sp_insert_emp_contact 3, 1, 6
sp_insert_emp_contact 1, 2, 4
sp_insert_emp_contact 1, 2, 5
sp_insert_emp_contact 3, 2, 7

--Payment
--sp_insert_payment pay_Desc, cartID
sp_insert_payment 'Paid', 2
sp_insert_payment 'Paid Cash', 4

--New account for user in website
--sp_insert_user custID, LoginName, loginPassword
sp_insert_user 1,ben12,'Newpassword'

--Promocode
--sp_insert_promocode pcode, deduction
sp_insert_promocode 'QWERTY2000',0.25
sp_insert_promocode 'ASDFG2001',0.50
sp_insert_promocode 'NOBUENO',0.0

--Supplier
--sp_insert_supplier supName, supMail
sp_insert_supplier 'Bandai Co','Bandai@info.com'
sp_insert_supplier 'Tokyo treasure','tokyotreasure@mail.com'
sp_insert_supplier 'yabe','yabestore@mail.com'
sp_insert_supplier 'AliStore','AS@mail.com'
sp_insert_supplier 'Alvin Boutik','AB99@yahoo.com'
sp_insert_supplier 'GarySama','GS@gmail.com'
sp_insert_supplier 'Golden Price SHOP','GPS@outlook.com'