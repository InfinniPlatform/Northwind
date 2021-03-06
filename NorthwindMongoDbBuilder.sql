declare @databaseName nvarchar(100)
set @databaseName = 'Northwind'

declare @item nvarchar(max)
declare @script table (Line int primary key identity, Command nvarchar(max))

declare @header nvarchar(max) set @header =
	'"_header" :{' +
		'"_tenant":"' + @databaseName + '",' +
		'"_created":ISODate("' + convert(nvarchar(max), getdate(), 127) + '"),' +
		'"_createUser":"' + (select top 1 lower(LastName) from Employees order by EmployeeID) + '",' +
		'"_createUserId":"' + (select top 1 cast(EmployeeID as nvarchar(100)) from Employees order by EmployeeID) + '"' +
	'},'

declare @systemHeader nvarchar(max) set @systemHeader =
	'"_header" :{' +
		'"_tenant":"system",' +
		'"_created":ISODate("' + convert(nvarchar(max), getdate(), 127) + '"),' +
		'"_createUser":"' + (select top 1 lower(LastName) from Employees order by EmployeeID) + '",' +
		'"_createUserId":"' + (select top 1 cast(EmployeeID as nvarchar(100)) from Employees order by EmployeeID) + '"' +
	'},'

insert into @script(Command) 
	select 'var connection = new Mongo();'
		union all
	select 'db = connection.getDB("' + @databaseName + '");'
		union all
	select ''
		union all
		
-- Customers

	select '// Customers'
		union all
	select ''
		union all
	select 'db.Customers.drop();'
		union all
	select ''
		union all
	select 'var bulk = db.Customers.initializeUnorderedBulkOp();'
		union all
	select
	'bulk.insert(' +
	'{' +
		'"_id":"' + c.CustomerID + '",' +
		@header +
		'"CompanyName":' + isnull('"' + c.CompanyName + '"', 'null') + ',' +
		'"ContactName":' + isnull('"' + c.ContactName + '"', 'null') + ',' +
		'"ContactTitle":' + isnull('"' + c.ContactTitle + '"', 'null') + ',' +
		'"Address":' + isnull('"' + c.Address + '"', 'null') + ',' +
		'"City":' + isnull('"' + c.City + '"', 'null') + ',' +
		'"Region":' + isnull('"' + c.Region + '"', 'null') + ',' +
		'"PostalCode":' + isnull('"' + c.PostalCode + '"', 'null') + ',' +
		'"Country":' + isnull('"' + c.Country + '"', 'null') + ',' +
		'"Phone":' + isnull('"' + c.Phone + '"', 'null') + ',' +
		'"Fax":' + isnull('"' + c.Fax + '"', 'null') +
	'}' +
	');'
	from Customers as c
		union all
	select 'bulk.execute();'
		union all
	select ''
		union all

-- Suppliers

	select '// Suppliers'
		union all
	select ''
		union all
	select 'db.Suppliers.drop();'
		union all
	select ''
		union all
	select 'var bulk = db.Suppliers.initializeUnorderedBulkOp();'
		union all
	select
	'bulk.insert(' +
	'{' +
		'"_id":NumberInt(' + cast(s.SupplierID as nvarchar(100)) + '),' +
		@header +
		'"CompanyName":' + isnull('"' + s.CompanyName + '"', 'null') + ',' +
		'"ContactName":' + isnull('"' + s.ContactName + '"', 'null') + ',' +
		'"ContactTitle":' + isnull('"' + s.ContactTitle + '"', 'null') + ',' +
		'"Address":' + isnull('"' + s.Address + '"', 'null') + ',' +
		'"City":' + isnull('"' + s.City + '"', 'null') + ',' +
		'"Region":' + isnull('"' + s.Region + '"', 'null') + ',' +
		'"PostalCode":' + isnull('"' + s.PostalCode + '"', 'null') + ',' +
		'"Country":' + isnull('"' + s.Country + '"', 'null') + ',' +
		'"Phone":' + isnull('"' + s.Phone + '"', 'null') + ',' +
		'"Fax":' + isnull('"' + s.Fax + '"', 'null') +
	'}' +
	');'
	from Suppliers as s
		union all
	select 'bulk.execute();'
		union all
	select ''
		union all

-- Products

	select '// Products'
		union all
	select ''
		union all
	select 'db.Products.drop();'
		union all
	select ''
		union all
	select 'var bulk = db.Products.initializeUnorderedBulkOp();'
		union all
	select
	'bulk.insert(' +
	'{' +
		'"_id":NumberInt(' + cast(p.ProductID as nvarchar(100)) + '),' +
		@header +
		'"ProductName":' + isnull('"' + p.ProductName + '"', 'null') + ',' +
		'"Supplier":{' +
			'"Id":NumberInt(' + cast(p.SupplierID as nvarchar(100)) + '),' +
			'"DisplayName":"' + s.CompanyName + '"' +
		'},' +
		'"Category":{' +
			'"Id":NumberInt(' + cast(p.CategoryID as nvarchar(100)) + '),' +
			'"DisplayName":"' + c.CategoryName + '"' +
		'},' +
		'"QuantityPerUnit":' + isnull('"' + p.QuantityPerUnit + '"', 'null') + ',' +
		'"UnitPrice":' + isnull(cast(p.UnitPrice as nvarchar(100)), 'null') + ',' +
		'"UnitsInStock":' + isnull('NumberInt(' + cast(p.UnitsInStock as nvarchar(100)) + ')', 'null') + ',' +
		'"UnitsOnOrder":' + isnull('NumberInt(' + cast(p.UnitsOnOrder as nvarchar(100)) + ')', 'null') + ',' +
		'"ReorderLevel":' + isnull('NumberInt(' + cast(p.ReorderLevel as nvarchar(100)) + ')', 'null') + ',' +
		'"Discontinued":' + case when p.Discontinued = 1 then 'true' else 'false' end +
	'}' +
	');'
	from Products as p
	left join Suppliers as s on s.SupplierID = p.SupplierID
	left join Categories as c on c.CategoryID = p.CategoryID
		union all
	select 'bulk.execute();'
		union all
	select ''
		union all

-- Categories

	select '// Categories'
		union all
	select ''
		union all
	select 'db.Categories.drop();'
		union all
	select ''
		union all
	select 'var bulk = db.Categories.initializeUnorderedBulkOp();'
		union all
	select
	'bulk.insert(' +
	'{' +
		'"_id":NumberInt(' + cast(c.CategoryID as nvarchar(100)) + '),' +
		@header +
		'"CategoryName":' + isnull('"' + c.CategoryName + '"', 'null') + ',' +
		'"Description":' + isnull('"' + cast(c.Description as nvarchar(max)) + '"', 'null') + ',' +
		'"Picture":' + isnull('BinData(0,"' +
				(select cast(N'' as xml).value('xs:base64Binary(sql:column("data"))', 'VARCHAR(max)')
					from (select substring(cast(c.Picture as varbinary(max)), 79, len(cast(c.Picture as varbinary(max))) - 78) as data) as base64Data) +
			'")', 'null') +
	'}' +
	');'
	from Categories as c
		union all
	select 'bulk.execute();'
		union all
	select ''
		union all

-- Regions

	select '// Regions'
		union all
	select ''
		union all
	select 'db.Regions.drop();'
		union all
	select ''
		union all
	select 'var bulk = db.Regions.initializeUnorderedBulkOp();'
		union all
	select
	'bulk.insert(' +
	'{' +
		'"_id":NumberInt(' + cast(r.RegionID as nvarchar(100)) + '),' +
		@header +
		'"RegionDescription":' + isnull('"' + rtrim(r.RegionDescription) + '"', 'null') +
	'}' +
	');'
	from Region as r
		union all
	select 'bulk.execute();'
		union all
	select ''
		union all

-- Territories

	select '// Territories'
		union all
	select ''
		union all
	select 'db.Territories.drop();'
		union all
	select ''
		union all
	select 'var bulk = db.Territories.initializeUnorderedBulkOp();'
		union all
	select
	'bulk.insert(' +
	'{' +
		'"_id":"' + t.TerritoryID + '",' +
		@header +
		'"TerritoryDescription":' + isnull('"' + rtrim(t.TerritoryDescription) + '"', 'null') + ',' +
		'"Region":{' +
			'"Id":NumberInt(' + cast(t.RegionID as nvarchar(100)) + '),' +
			'"DisplayName":"' + r.RegionDescription + '"' +
		'}' +
	'}' +
	');'
	from Territories as t
	left join Region as r on r.RegionID = t.RegionID
		union all
	select 'bulk.execute();'
		union all
	select ''
		union all

-- Shippers

	select '// Shippers'
		union all
	select ''
		union all
	select 'db.Shippers.drop();'
		union all
	select ''
		union all
	select 'var bulk = db.Shippers.initializeUnorderedBulkOp();'
		union all
	select
	'bulk.insert(' +
	'{' +
		'"_id":NumberInt(' + cast(s.ShipperID as nvarchar(100)) + '),' +
		@header +
		'"CompanyName":' + isnull('"' + s.CompanyName + '"', 'null') + ',' +
		'"Phone":' + isnull('"' + s.Phone + '"', 'null') +
	'}' +
	');'
	from Shippers as s
		union all
	select 'bulk.execute();'
		union all
	select ''
		union all

-- Employees

	select '// Employees'
		union all
	select ''
		union all
	select 'db.Employees.drop();'
		union all
	select ''
		union all
	select 'bulk = db.Employees.initializeUnorderedBulkOp();'
		union all
	select
	'bulk.insert(' +
	'{' +
		'"_id":NumberInt(' + cast(e.EmployeeID as nvarchar(100)) + '),' +
		@header +
		'"LastName":' + isnull('"' + e.LastName + '"', 'null') + ',' +
		'"FirstName":' + isnull('"' + e.FirstName + '"', 'null') + ',' +
		'"Title":' + isnull('"' + e.Title + '"', 'null') + ',' +
		'"TitleOfCourtesy":' + isnull('"' + e.TitleOfCourtesy + '"', 'null') + ',' +
		'"BirthDate":' + isnull('ISODate("' + convert(nvarchar(max), e.BirthDate, 127) + '")', 'null') + ',' +
		'"HireDate":' + isnull('ISODate("' + convert(nvarchar(max), e.HireDate, 127) + '")', 'null') + ',' +
		'"Address":' + isnull('"' + replace(replace(e.Address, char(13), ''), char(10), '') + '"', 'null') + ',' +
		'"City":' + isnull('"' + e.City + '"', 'null') + ',' +
		'"Region":' + isnull('"' + e.Region + '"', 'null') + ',' +
		'"PostalCode":' + isnull('"' + e.PostalCode + '"', 'null') + ',' +
		'"Country":' + isnull('"' + e.Country + '"', 'null') + ',' +
		'"HomePhone":' + isnull('"' + e.HomePhone + '"', 'null') + ',' +
		'"Extension":' + isnull('"' + e.Extension + '"', 'null') + ',' +
		'"Photo":' + isnull('BinData(0,"' +
				(select cast(N'' as xml).value('xs:base64Binary(sql:column("data"))', 'VARCHAR(max)')
					from (select substring(cast(e.Photo as varbinary(max)), 79, len(cast(e.Photo as varbinary(max))) - 78) as data) as base64Data) +
			'")', 'null') + ',' +
		'"Notes":' + isnull('"' + replace(cast(e.Notes as nvarchar(max)), '"', '\"') + '"', 'null') + ',' +
		'"ReportsTo":' + isnull('{' +
			'"Id":NumberInt(' + cast(re.EmployeeID as nvarchar(100)) + '),' +
			'"DisplayName":"' + re.FirstName + ' ' + re.LastName + '"' +
		'}', 'null') + ',' +
		'"PhotoPath":' + isnull('"' + e.PhotoPath + '"', 'null') + ',' +
		'"Territories":[' + substring(t.Territories, 1, len(t.Territories) - 1) + ']' +
	'}' +
	');'
	from Employees as e
	left join Employees as re on re.EmployeeID = e.EmployeeID
	left join (
		select et.EmployeeID, (
			select
			'{' +
				'"Id":"' + cast(x.TerritoryID as nvarchar(100)) + '",' +
				'"DisplayName":"' + rtrim(t.TerritoryDescription) + '"' +
			'},'
			from EmployeeTerritories as x
			left join Territories as t on t.TerritoryID = x.TerritoryID
			where x.EmployeeID = et.EmployeeID
			for xml path('')
		) as Territories
		from EmployeeTerritories as et
		group by et.EmployeeID
	) as t on t.EmployeeID = e.EmployeeID
		union all
	select 'bulk.execute();'
		union all
	select ''
		union all

-- Orders

	select '// Orders'
		union all
	select ''
		union all
	select 'db.Orders.drop();'
		union all
	select ''
		union all
	select 'bulk = db.Orders.initializeUnorderedBulkOp();'
		union all
	select
	'bulk.insert(' +
	'{' +
		'"_id":NumberInt(' + cast(o.OrderID as nvarchar(100)) + '),' +
		@header +
		'"Customer":{' +
			'"Id":"' + o.CustomerID + '",' +
			'"DisplayName":"' + c.CompanyName + '"' +
		'},' +
		'"Employee":{' +
			'"Id":NumberInt(' + cast(o.EmployeeID as nvarchar(100)) + '),' +
			'"DisplayName":"' + e.FirstName + ' ' + e.LastName + '"' +
		'},' +
		'"OrderDate":' + isnull('ISODate("' + convert(nvarchar(max), o.OrderDate, 127) + '")', 'null') + ',' +
		'"RequiredDate":' + isnull('ISODate("' + convert(nvarchar(max), o.RequiredDate, 127) + '")', 'null') + ',' +
		'"ShippedDate":' + isnull('ISODate("' + convert(nvarchar(max), o.ShippedDate, 127) + '")', 'null') + ',' +
		'"ShipVia":{' +
			'"Id":NumberInt(' + cast(o.ShipVia as nvarchar(100)) + '),' +
			'"DisplayName":"' + s.CompanyName + '"' +
		'},' +
		'"Freight":' + cast(o.Freight as nvarchar(100)) + ',' +
		'"ShipName":' + isnull('"' + o.ShipName + '"', 'null') + ',' +
		'"ShipAddress":' + isnull('"' + o.ShipAddress + '"', 'null') + ',' +
		'"ShipCity":' + isnull('"' + o.ShipCity + '"', 'null') + ',' +
		'"ShipRegion":' + isnull('"' + o.ShipRegion + '"', 'null') + ',' +
		'"ShipPostalCode":' + isnull('"' + o.ShipPostalCode + '"', 'null') + ',' +
		'"ShipCountry":' + isnull('"' + o.ShipCountry + '"', 'null') + ',' +
		'"Details":[' + substring(od.Details, 1, len(od.Details) - 1) + ']' +
	'}' +
	');'
	from Orders as o
	left join Customers as c on c.CustomerID = o.CustomerID
	left join Employees as e on e.EmployeeID = o.EmployeeID
	left join Shippers as s on s.ShipperID = o.ShipVia
	left join (
		select d.OrderID, (
			select
			'{' +
				'"Product":{' +
					'"Id":NumberInt(' + cast(x.ProductID as nvarchar(100)) + '),' +
					'"DisplayName":"' + p.ProductName + '"' +
				'},' +
				'"UnitPrice":' + cast(x.UnitPrice as nvarchar(100)) + ',' +
				'"Quantity":' + cast(x.Quantity as nvarchar(100)) + ',' +
				'"Discount":' + cast(x.Discount as nvarchar(100)) +
			'},'
			from [Order Details] as x
			left join Products as p on p.ProductID = x.ProductID
			where x.OrderID = d.OrderID
			for xml path('')
		) as Details
		from [Order Details] as d
		group by d.OrderID
	) as od on od.OrderID = o.OrderID
		union all
	select 'bulk.execute();'
		union all
	select ''
		union all

-- UserStore

	select '// UserStore'
		union all
	select ''
		union all
	select 'db.UserStore.drop();'
		union all
	select ''
		union all
	select 'bulk = db.UserStore.initializeUnorderedBulkOp();'
		union all
	select
	'bulk.insert(' +
	'{' +
		'"_id":"' + cast(e.EmployeeID as nvarchar(100)) + '",' +
		@systemHeader +
		'"UserName":"' + lower(e.LastName) + '",' +
		'"Email":"' + lower(e.LastName) + '@northwind.com' + '",' +
		'"EmailConfirmed":true,' +
		'"PasswordHash":"AAGJpallElctFPV1i0waXTo22jTWCuYGvI+UdNDqD5MdS7Zh9Mce1ByfdMiLNJZLIA==",' + -- Password: Qwerty123
		'"SecurityStamp":"' + cast(newid() as nvarchar(100)) + '",' +
		'"Claims":[' +
			'{"Type":"tenantid","Value":"' + @databaseName + '"}' +
		']' +
	'}' +
	');'
	from Employees as e
		union all
	select 'bulk.execute();'
		union all
	select ''

select Command from @script order by Line
