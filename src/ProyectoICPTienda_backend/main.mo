import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Float "mo:base/Float";
import Array "mo:base/Array";

import Types "./Types";
actor {
    /**
  ==============================
  ====  Customers section  =====
  ==============================
  */

    var custormerId : Nat = 0;
    let customers = HashMap.HashMap<Text, Types.Customer>(0, Text.equal, Text.hash);

    /**
    * Función para agregar un cliente
    * Recibe un objeto de tipo Customer
    * Retorna el ID del nuevo cliente
    */
    public func AddCustomer(customer : Types.Customer) : async Text {
        let newId = generateCustomerId();
        customers.put(newId, customer);
        return newId;
    };

    /**
    * Función privada para generar un nuevo ID de cliente
    * Retorna el ID del nuevo cliente como texto
    */
    private func generateCustomerId() : Text {
        custormerId += 1;
        return Nat.toText(custormerId);
    };

    /**
    * Función para obtener un cliente por su ID
    * Recibe el ID del cliente como texto
    * Retorna un objeto de tipo Customer o null si no se encuentra
    */
    public query func getCustomer(key : Text) : async ?Types.Customer {
        customers.get(key);
    };

    /**
    * Función para obtener todos los clientes
    * Retorna una lista de tuplas con el ID del cliente y el objeto Customer
    */
    public query func getcustomers() : async [(Text, Types.Customer)] {
        let customerIter : Iter.Iter<(Text, Types.Customer)> = customers.entries();
        Iter.toArray(customerIter);
    };

    /**
    * Función para actualizar un cliente
    * Recibe el ID del cliente y el objeto Customer actualizado
    * Retorna true si la actualización fue exitosa, false en caso contrario
    */
    public func UpdateCustomer(customerId : Text, updatedCustomer : Types.Customer) : async Bool {
        switch (customers.get(customerId)) {
            case (?_) {
                customers.put(customerId, updatedCustomer);
                return true;
            };
            case (_) {
                return false;
            };
        };
    };

    /**
    * Función para eliminar un cliente
    * Recibe el ID del cliente
    * Retorna true si la eliminación fue exitosa, false en caso contrario
    */
    public func DeleteCustomer(customerId : Text) : async Bool {
        switch (customers.remove(customerId)) {
            case (?_) { return true };
            case (_) { return false };
        };
    };

    /**
  ==============================
  ====  Inventory section  =====
  ==============================
  */

    var producId : Nat = 0;
    let products = HashMap.HashMap<Text, Types.Product>(0, Text.equal, Text.hash);

    /**
    * Función para agregar un producto
    * Recibe un objeto de tipo Product
    * Retorna el ID del nuevo producto
    */
    public func AddProduct(product : Types.Product) : async Text {
        let newId = generateProductId();
        products.put(newId, product);
        return newId;
    };

    /**
    * Función privada para generar un nuevo ID de producto
    * Retorna el ID del nuevo producto como texto
    */
    private func generateProductId() : Text {
        producId += 1;
        return Nat.toText(producId);
    };

    /**
    * Función para obtener un producto por su ID
    * Recibe el ID del producto como texto
    * Retorna un objeto de tipo Product o null si no se encuentra
    */
    public query func getProduct(key : Text) : async ?Types.Product {
        products.get(key);
    };

    /**
    * Función para obtener todos los productos
    * Retorna una lista de tuplas con el ID del producto y el objeto Product
    */
    public query func getProducts() : async [(Text, Types.Product)] {
        let producIter : Iter.Iter<(Text, Types.Product)> = products.entries();
        Iter.toArray(producIter);
    };

    /**
    * Función para actualizar un producto
    * Recibe el ID del producto y el objeto Product actualizado
    * Retorna true si la actualización fue exitosa, false en caso contrario
    */
    public func UpdateProduct(productId : Text, updatedProduct : Types.Product) : async Bool {
        switch (products.get(productId)) {
            case (?_) {
                products.put(productId, updatedProduct);
                return true;
            };
            case (_) {
                return false;
            };
        };
    };

    /**
    * Función para eliminar un producto
    * Recibe el ID del producto
    * Retorna true si la eliminación fue exitosa, false en caso contrario
    */
    public func DeleteProduct(productId : Text) : async Bool {
        switch (products.remove(productId)) {
            case (?_) { return true };
            case (_) { return false };
        };
    };

    /**
  ==============================
  ====  Sales section  =====
  ==============================
  */

    var salesId : Nat = 0;
    let sales = HashMap.HashMap<Text, Types.Sale>(0, Text.equal, Text.hash);

    /**
    * Función para agregar una venta
    * Recibe el ID del cliente y una lista de compras (ProductId y Quantity)
    * Retorna el ID de la nueva venta o null si no se puede realizar la venta
    */
    public func AddSale(CustomerId : Text, Purchases : [{ ProductId : Text; Quantity : Int }]) : async ?Text {
        if (not validateProductQuantities(Purchases)) {
            return null;
        };

        let newId = generateSaleId();
        var purchasesList : [Types.ProductPurchase] = [];
        for (purchase in Iter.fromArray(Purchases)) {
            let total = calculateTotal(purchase.ProductId, purchase.Quantity);
            purchasesList := Array.append(purchasesList, [{ ProductId = purchase.ProductId; Quantity = purchase.Quantity; Total = total }]);
            // Actualiza la cantidad del producto en el inventario
            let productOpt = products.get(purchase.ProductId);
            switch (productOpt) {
                case (?product) {
                    let updatedProduct = {
                        product with Quantity = product.Quantity - purchase.Quantity
                    };
                    products.put(purchase.ProductId, updatedProduct);
                };
                case (_) {};
            };
        };
        let sale : Types.Sale = {
            CustomerId = CustomerId;
            Purchases = purchasesList;
        };
        sales.put(newId, sale);
        return ?newId;
    };

    /**
    * Función privada para validar las cantidades de productos
    * Recibe una lista de compras (ProductId y Quantity)
    * Retorna true si todas las cantidades son suficientes, false en caso contrario
    */
    private func validateProductQuantities(Purchases : [{ ProductId : Text; Quantity : Int }]) : Bool {
        for (purchase in Iter.fromArray(Purchases)) {
            let productOpt = products.get(purchase.ProductId);
            switch (productOpt) {
                case (?product) {
                    if (product.Quantity < purchase.Quantity) {
                        return false; // No hay suficiente cantidad
                    };
                };
                case (_) {
                    return false; // El producto no existe
                };
            };
        };
        return true; // Todas las cantidades son suficientes
    };

    /**
    * Función privada para calcular el total de una compra
    * Recibe el ID del producto y la cantidad
    * Retorna el total como un valor flotante
    */
    private func calculateTotal(idProduct : Text, Quantity : Int) : Float {
        let product = products.get(idProduct);
        switch (product) {
            case (?p) {
                return p.Price * Float.fromInt(Quantity);
            };
            case (_) {
                return 0.0;
            };
        };
    };

    /**
    * Función privada para generar un nuevo ID de venta
    * Retorna el ID de la nueva venta como texto
    */
    private func generateSaleId() : Text {
        salesId += 1;
        return Nat.toText(salesId);
    };

    /**
    * Función para obtener una venta por su ID
    * Recibe el ID de la venta como texto
    * Retorna un objeto de tipo Sale o null si no se encuentra
    */
    public query func getSale(key : Text) : async ?Types.Sale {
        sales.get(key);
    };

    /**
    * Función para obtener todas las ventas
    * Retorna una lista de tuplas con el ID de la venta y el objeto Sale
    */
    public query func getSales() : async [(Text, Types.Sale)] {
        let saleIter : Iter.Iter<(Text, Types.Sale)> = sales.entries();
        Iter.toArray(saleIter);
    };

    /**
    * Función para actualizar una venta
    * Recibe el ID de la venta, el ID del cliente actualizado y una lista de compras actualizadas (ProductId y Quantity)
    * Retorna true si la actualización fue exitosa, false en caso contrario
    */
    public func UpdateSale(saleId : Text, updatedCustomer : Text, updatedPurchases : [{ ProductId : Text; Quantity : Int }]) : async Bool {
        if (not validateProductQuantities(updatedPurchases)) {
            return false;
        };

        switch (sales.get(saleId)) {
            case (?_) {
                var updatedPurchasesList : [Types.ProductPurchase] = [];
                for (purchase in Iter.fromArray(updatedPurchases)) {
                    let newTotal = calculateTotal(purchase.ProductId, purchase.Quantity);
                    updatedPurchasesList := Array.append(updatedPurchasesList, [{ ProductId = purchase.ProductId; Quantity = purchase.Quantity; Total = newTotal }]);
                    // Actualiza la cantidad del producto en el inventario
                    let productOpt = products.get(purchase.ProductId);
                    switch (productOpt) {
                        case (?product) {
                            let updatedProduct = {
                                product with Quantity = product.Quantity - purchase.Quantity
                            };
                            products.put(purchase.ProductId, updatedProduct);
                        };
                        case (_) {};
                    };
                };
                let newSale : Types.Sale = {
                    CustomerId = updatedCustomer;
                    Purchases = updatedPurchasesList;
                };
                sales.put(saleId, newSale);
                return true;
            };
            case (_) {
                return false;
            };
        };
    };

    /**
    * Función para eliminar una venta
    * Recibe el ID de la venta
    * Retorna true si la eliminación fue exitosa, false en caso contrario
    */
    public func DeleteSale(saleId : Text) : async Bool {
        switch (sales.remove(saleId)) {
            case (?_) { return true };
            case (_) { return false };
        };
    };
};
