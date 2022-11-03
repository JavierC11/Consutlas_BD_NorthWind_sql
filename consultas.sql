--CONSULTAS SQL NORTHWIND--

--1) Dar el nombre de los productos y el nombre de categorías,
--agrupado por categorías y en orden alfabetico.
SELECT C.CATEGORYNAME, P.PRODUCTNAME
FROM CATEGORIES C 
INNER JOIN PRODUCTS P ON C.CATEGORYID = P.CATEGORYID
ORDER BY C.CATEGORYNAME ASC;



--2) Dar el nombre del proveedor y los productos que él haya provisto,
-- donde por lo menos tenga 3 de sus producto que estén en una o mar órdenes.
SELECT P.PRODUCTNAME PRODUCTO,S.COMPANYNAME PROVEEDOR 
FROM SUPPLIERS S
INNER JOIN PRODUCTS P ON P.SUPPLIERID = S.SUPPLIERID
WHERE P.PRODUCTID IN (
                        SELECT O.PRODUCTID 
                        FROM ORDERDETAILS O
                        GROUP BY O.PRODUCTID
                        HAVING COUNT(DISTINCT O.PRODUCTID)>=3
                    ) 
ORDER BY S.COMPANYNAME,P.PRODUCTNAME;



-- 3) Dar el nombre del transportista (shippers) y todos sus órdenes que el haya enviado, i
--incluyendo la fecha de requerimiento (requiredate) y la fecha de entrega (shipperdate), o
--ordenados por fecha de entrega.
SELECT S.COMPANYNAME AS NOMBRE_TRANSPORTISTA, O.ORDERID, O.REQUIREDDATE, O.SHIPPEDDATE 
FROM ORDERS O INNER JOIN SHIPPERS S ON O.SHIPVIA = S.SHIPPERID
WHERE O.SHIPPEDDATE IS NOT NULL
ORDER BY O.SHIPPEDDATE;



--4) Dar el nombre de todos los clientes que ha recibido sus paquetes por el
-- transportista “Speedy Express”, y que haya sido atendido por un empleado que no
-- tenga mando.
SELECT C.COMPANYNAME AS "NOMBRE DEL CLIENTE", S.COMPANYNAME AS "NOMBRE DEL TRANSPORTISTA" , E.FIRSTNAME ||' '||E.LASTNAME AS "NOMBRE DEL JEFE", E.REPORTSTO 
FROM EMPLOYEES E INNER JOIN ORDERS O ON E.EMPLOYEEID =  O.EMPLOYEEID 
INNER JOIN SHIPPERS S ON O.SHIPVIA = S.SHIPPERID
INNER JOIN CUSTOMERS C ON O.CUSTOMERID = C.CUSTOMERID
WHERE E.REPORTSTO IS NULL AND
S.COMPANYNAME = 'Speedy Express';



--5) Dar el nombre completo del empleado, nombre de la región y nombre del
-- territorio que no haya hecho ninguna orden.
--REVISAR CON CUATE DE DANNI
SELECT E.FIRSTNAME ||' '||E.LASTNAME AS NOMBRE_COMPLETO, R.REGIONDESCRIPTION, T.TERRITORYDESCRIPTION
FROM EMPLOYEES E INNER JOIN EMPLOYEETERRITORIES ET ON E.EMPLOYEEID = ET.EMPLOYEEID
INNER JOIN TERRITORIES T ON ET.TERRITORYID = T.TERRITORYID
INNER JOIN REGION R ON T.REGIONID = R.REGIONID
WHERE E.EMPLOYEEID IN (
                        SELECT E1.EMPLOYEEID
                        FROM EMPLOYEES E1
                        INNER JOIN ORDERS O ON E1.EMPLOYEEID = O.EMPLOYEEID 
                        WHERE O.EMPLOYEEID IS NULL)
ORDER BY E.FIRSTNAME ||' '||E.LASTNAME;
--No nos muestra ningun resultado pues todos lo empleados tienen ordenes



--6) Dar el nombre de los proveedores que hayan distribuido los
--productos “Chang”, “Tofu” y “Pavlova” en donde cada proveedor
--por lo menos tenga 5 productos que le distribuye y al menos 50
--clientes hayan pedido alguno de los productos distribuidos
select S.CompanyName, (Select count(*) from PRODUCTS p2 where p2.SupplierId = p.SupplierId) as NumeroProducto,  
(Select count(*) from ORDERDETAILS o where o.ProductID = p.ProductID) as NumeroClientes
from PRODUCTS p
inner join SUPPLIERS S on S.SupplierID = p.SupplierID
Where (p.ProductName = 'Chang' or  p.ProductName = 'Tofu' or  p.ProductName = 'Pavlova') 
and (Select count(*) from PRODUCTS p2 where p2.SupplierId = p.SupplierId)>=5 
and (Select count(*) from ORDERDETAILS o where o.ProductID = p.ProductID) >=50;



--7) Dar el nombre y apellido del empleado que realizaron una o más órdenes
--y el conteo de órdenes que tiene por cada empleado y donde tenga uno
-- o más productos de todas las categorías que existe, y que su número de
-- órdenes que haya hecho sea mayor a 2.
SELECT E.FIRSTNAME,E.LASTNAME,COUNT(O.ORDERID) 
FROM EMPLOYEES E
INNER JOIN ORDERS O ON E.EMPLOYEEID = O.EMPLOYEEID 
WHERE O.ORDERID IN (
                    SELECT OD.ORDERID
                    FROM ORDERSDETAILS OD
                    INNER JOIN PRODUCTS P ON OD.PRDUCTID = P.PRODUCTID 
                    INNER JOIN CATEGORIES C ON P.CATEGORYID = C.CATEGORYID
                    GROUP BY OD.ORDERID
                    HAVING COUNT(DISTINCT C.CATEGORYID) = ( SELECT COUNT(CATEGORYID) 
                                                            FROM CATEGORIES))
GROUP BY E.FIRSTNAME,E.LASTNAME;



--8)  Dar el nombre de los productos y su cantidad de veces que han
--sido comprados por los clientes, ordenemos de mayor a menor
--según su cantidad.                          
SELECT distinct p1.productname , quantity
from orderdetails od , products p1
where p1.productid = od.productid and
od.productid = od.quantity  
order by  od.quantity DESC;



--9) Dar el nombre de los proveedores y su teléfono que haya distribuido
-- el producto con categoría “Seefood”, pero garantizando que por
-- lo menos tenga una orden de pedido, ordenados alfabéticamente por
-- nombre de proveedor.
--se debe cambiar
SELECT S.COMPANYNAME, S.PHONE, C.CATEGORYNAME, OD.QUANTITY
FROM ORDERDETAILS OD INNER JOIN PRODUCTS P ON OD.PRODUCTID = P.PRODUCTID
INNER JOIN CATEGORIES C ON P.CATEGORYID = C.CATEGORYID 
INNER JOIN SUPPLIERS S ON P.SUPPLIERID = S.SUPPLIERID
WHERE OD.QUANTITY > 0 AND
C.CATEGORYNAME = 'Seafood'
ORDER BY S.COMPANYNAME ASC;



--10) Haga el organigrama usando la tabla Employees y la columna
--Reportsto, para devolver, el jefe y sus respectivos subordinados,
--estos tienen que estar agrupados por jefe.
SELECT B.FIRSTNAME AS "NOMBRE DEL JEFE", B.LASTNAME AS "APELLIDO DEL JEFE" ,E.LASTNAME AS "APELLIDO DEL EMPLEADO", E.REPORTSTO
FROM EMPLOYEES E, EMPLOYEES B
WHERE  E.REPORTSTO = b.EMPLOYEEID
order by  E.REPORTSTO ASC;



--11) (Utilizando Inner join y subconsultas), Cree un script, que
-- muestre el código del cliente de todo aquel que haya pedido más
-- de 2 unidades del producto 23
SELECT C.CUSTOMERID, C.CONTACTNAME, OD.QUANTITY
FROM ORDERDETAILS OD INNER JOIN ORDERS O ON OD.ORDERID = O.ORDERID
INNER JOIN CUSTOMERS C ON O.CUSTOMERID = C.CUSTOMERID
WHERE OD.QUANTITY > 2 AND
OD.PRODUCTID IN (
                SELECT OD.PRODUCTID
                FROM ORDERDETAILS OD
                WHERE OD.PRODUCTID = 23
);



--12) Cree un script que devuelva los 5 productos más vendidos por
--categoría de producto (Categories), para determinar los productos
--más vendidos, use el número de unidades vendidas de cada orden.
SELECT PRODUCTNAME,NOMBRE_CATEGORIA, CANTIDAD_VENTA 
FROM (
        SELECT  P.PRODUCTNAME, C.CATEGORYNAME NOMBRE_CATEGORIA, SUM(OD.QUANTITY) CANTIDAD_VENTA, 
                ROW_NUMBER() OVER (PARTITION BY C.CATEGORYNAME ORDER BY SUM(OD.QUANTITY) DESC) NUMERO
        FROM CATEGORIES C
        INNER JOIN PRODUCTS P ON P.CATEGORYID = C.CATEGORYID
        INNER JOIN ORDERDETAILS OD ON P.PRODUCTID = OD.PRODUCTID
        GROUP BY C.CATEGORYNAME,P.PRODUCTNAME
        ORDER BY C.CATEGORYNAME, NUMERO,P.PRODUCTNAME, SUM(OD.QUANTITY) DESC
)
WHERE NUMERO <= 5;



--13 Cree un script en donde me despliegue el nombre y apellido del
--empleado que haya realizados 3 pedidos o más y que la sumatoria
--de sus productos solicitados sea mayor a 2 por cada pedido y que
--al menos en cada pedido pueden estar los productos “Gnocchi di
--nonna Alice”, “Ikura”, “Queso Cabrales”, “Singaporean Hokkien
--Fried Mee” o “Tofu”
SELECT E.FIRSTNAME,E.LASTNAME
FROM EMPLOYEES E
INNER JOIN ORDERS O ON O.EMPLOYEEID = E.EMPLOYEEID 
INNER JOIN ORDERDETAILS OD ON OD.ORDERID = O.ORDERID 
WHERE O.ORDERID IN (
                    SELECT ORDE.ORDERID
                    FROM ORDERS ORDE
                    INNER JOIN ORDERDETAILS ODT ON ODT.ORDERID = ORDE.ORDERID
                    INNER JOIN PRODUCTS P ON P.PRODUCTID = ODT.PRODUCTID 
                    WHERE P.PRODUCTNAME IN ('GNOCCHI DINONNA ALICE', 'IKURA', 'QUESO CABRALES','SINGAPOREAN HOKKIEN FRIED MEE', 'TOFU')
                    
AND ORDE.ORDERID = O.ORDERID )
GROUP BY E.FIRSTNAME, E.LASTNAME
HAVING COUNT(DISTINCT O.ORDERID) >= 3 AND SUM(OD.QUANTITY) > 2;



--14) Cree un script que muestre nombre del cliente que haya tenido más pedidos
-- que todos los demás clientes.
--MANERA CORRECTA
--Intentar hacerlo en el WHERE por que al inge no le gusta en el FROM
SELECT C.CONTACTNAME AS NOMBRE_DEL_CLIENTE, COUNT(O.ORDERID) AS TOTAL_DE_ORDENES
FROM ORDERS O, CUSTOMERS C
WHERE O.CUSTOMERID =  C.CUSTOMERID
GROUP BY C.CONTACTNAME
ORDER BY TOTAL_DE_ORDENES DESC
FETCH FIRST ROW ONLY;



--15) Dar el nombre del cliente y el nombre del producto con su código, más comprado.
--DE TODAS LAS ORDEENES EL PRODUC MAS VENDIDO  Y PONER EL NOMBRE DEL CUSTOMER`
--MANERA CORRECA
--deben ser todos los clientes del producto mas comprado    
SELECT C.CONTACTNAME, P.PRODUCTNAME, P.PRODUCTID, SUM(OD.QUANTITY) AS CANTIDAD_VENDIDA
FROM CUSTOMERS C INNER JOIN ORDERS O ON C.CUSTOMERID = O.CUSTOMERID
INNER JOIN ORDERDETAILS OD ON O.ORDERID = OD.ORDERID
INNER JOIN PRODUCTS P ON OD.PRODUCTID = P.PRODUCTID
GROUP BY C.CONTACTNAME, P.PRODUCTNAME, P.PRODUCTID
ORDER BY SUM(OD.QUANTITY) DESC
FETCH FIRST 2 ROW ONLY;



--16) Dar el nombre de los 5 clientes quienes más dinero gastaron junto con los cinco
-- clientes que menos gastaron, cree una columna que indique si corresponde a los
-- que más o menos gastaron.
--oracle--oracle
SELECT *
FROM(    
    SELECT C.CONTACTNAME, SUM((OD.Quantity*OD.UnitPrice)*(1-OD.Discount)) AS TOTAL, 'Mas Gastaron' AS GASTO 
    FROM customers C INNER JOIN orders O ON O.CUSTOMERID = C.CUSTOMERID 
    INNER JOIN orderdetails OD ON OD.OrderID = O.OrderID 
    GROUP BY C.CONTACTNAME
    ORDER BY SUM(OD.Quantity*OD.UnitPrice)  DESC 
    FETCH FIRST 5 ROW ONLY) mas_gastaron
UNION ALL 
SELECT *
FROM (
    SELECT C1.CONTACTNAME, SUM((OD1.Quantity*OD1.UnitPrice)*(1-OD1.Discount)) AS TOTAL, 'Menos Gastaron' AS GASTO 
    FROM customers C1 INNER JOIN orders O1 ON O1.CUSTOMERID = C1.CUSTOMERID 
    INNER JOIN orderdetails OD1 ON OD1.OrderID = O1.OrderID 
    GROUP BY CONTACTNAME  
    ORDER BY SUM((OD1.Quantity*OD1.UnitPrice)-OD1.Discount) ASC 
    FETCH FIRST 5 ROW ONLY) menos_gastaron;



--17) Dar el nombre y apellido del Jefe de los empleados que haya obtenido más ordenes
-- realizadas y que en esas órdenes tuvieron que haber vendido al menos 5
-- productos en cada orden.
SELECT B.FIRSTNAME||' '|| B.LASTNAME AS NOMBRE_COMPLETO_JEFE, E.FIRSTNAME AS NOMBRE_EMPLEADO, COUNT(O.ORDERID) AS NUMERO_ORDENES
FROM EMPLOYEES B 
INNER JOIN EMPLOYEES E ON B.EMPLOYEEID = E.REPORTSTO
INNER JOIN ORDERS O ON E.EMPLOYEEID = O.EMPLOYEEID
INNER JOIN ORDERDETAILS OD ON O.ORDERID = OD.ORDERID
INNER JOIN PRODUCTS P ON OD.PRODUCTID = P.PRODUCTID
GROUP BY B.FIRSTNAME||' '|| B.LASTNAME, E.FIRSTNAME
HAVING COUNT (DISTINCT P.PRODUCTID)> 5
ORDER BY NUMERO_ORDENES DESC;



--18)Dar el nombre del transportista (shippers) que haya trasportado
--uno más producto de la categoría “Confections”, pero que a su vez
--estén en 2 o más órdenes y que sean de distintos cliente
--SUBQUERY
SELECT S.COMPANYNAME NOMBRE_TRANSPORTISTA
FROM SHIPPERS S 
INNER JOIN ORDERS O ON S.SHIPPERID = O.SHIPVIA
--INNER JOIN CUSTOMERS CU ON O.CUSTOMERID = CU.CUSTOMERID 
INNER JOIN ORDERDETAILS OD ON O.ORDERID = OD.ORDERID
INNER JOIN PRODUCTS P ON OD.PRODUCTID = P.PRODUCTID
INNER JOIN CATEGORIES C ON P.CATEGORYID = C.CATEGORYID
WHERE P.PRODUCTID IN(
                        SELECT P1.PRODUCTID
                        FROM PRODUCTS P1 
                        INNER JOIN CATEGORIES C1 ON P1.CATEGORYID = C1.CATEGORYID
                        INNER JOIN ORDERDETAILS OD1 ON P1.PRODUCTID = OD1.PRODUCTID
                        INNER JOIN ORDERS O1 ON OD1.ORDERID = O1.ORDERID
                        INNER JOIN CUSTOMERS CU1 ON O1.CUSTOMERID = CU1.CUSTOMERID
                        WHERE C1.CATEGORYNAME = 'Confections'
                        HAVING COUNT(DISTINCT O1.ORDERID) >= 2  AND COUNT(DISTINCT CU1.COMPANYNAME) >= 2
                        GROUP BY  P1.PRODUCTID
)
HAVING COUNT(DISTINCT P.PRODUCTID) > 2
GROUP BY S.COMPANYNAME;



--19) Dar el nombre del empleado que haya estado en más de dos territorios, y que por lo menos haya
--hecho una orden en cada territorio, y que en cada orden contenga al menos 2 o más productos.
--QUERY PRINCIPAL
SELECT E.FIRSTNAME ||' '||E.LASTNAME NOMBRE_COMPLETO, T.TERRITORYDESCRIPTION TERRITORIO, COUNT(O1.ORDERID) TOTAL_ORDENES
FROM ORDERS O1 
INNER JOIN EMPLOYEES E ON O1.EMPLOYEEID = E.EMPLOYEEID
INNER JOIN EMPLOYEETERRITORIES ET ON E.EMPLOYEEID = ET.EMPLOYEEID
INNER JOIN TERRITORIES T ON ET.TERRITORYID = T.TERRITORYID
WHERE O1.ORDERID IS NOT NULL
AND O1.ORDERID IN (
            SELECT OD.ORDERID
            FROM ORDERDETAILS OD
            INNER JOIN PRODUCTS P ON OD.PRODUCTID =  P.PRODUCTID
            HAVING COUNT(OD.PRODUCTID) > 1
            GROUP BY OD.ORDERID
)
HAVING COUNT(DISTINCT T.TERRITORYDESCRIPTION)>2  
GROUP BY E.FIRSTNAME ||' '||E.LASTNAME, T.TERRITORYDESCRIPTION
ORDER BY E.FIRSTNAME ||' '||E.LASTNAME, T.TERRITORYDESCRIPTION;



--20) Dar el nombre del cliente que haya tenido mayor número de pedidos, y que cada pedido al
--menos tenga en lista 2 productos de la misma categoría..
SELECT CU.COMPANYNAME, COUNT(OD1.ORDERID) AS NUMERO_ORDENES
FROM CUSTOMERS CU
INNER JOIN ORDERS O ON CU.CUSTOMERID = O.CUSTOMERID
INNER JOIN ORDERDETAILS OD1 ON O.ORDERID = OD1.ORDERID
WHERE EXISTS (   
                    SELECT DISTINCT OD.ORDERID
                    FROM ORDERDETAILS OD 
                    INNER JOIN PRODUCTS P ON OD.PRODUCTID = P.PRODUCTID
                    INNER JOIN CATEGORIES C ON P.CATEGORYID = C.CATEGORYID
                    GROUP BY OD.ORDERID, C.CATEGORYID, C.CATEGORYNAME
                    HAVING COUNT(C.CATEGORYID)> 1
)
GROUP BY CU.COMPANYNAME
ORDER BY COUNT(OD1.ORDERID) DESC
FETCH FIRST 1 ROW ONLY;