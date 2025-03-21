module {
    public type Product = {
        Name : Text;
        Quantity : Int;
        Price : Float;
    };

    public type Customer = {
        FisrtName : Text;
        LastName : Text;
        Age : Int;
    };

    public type ProductPurchase = {
        ProductId : Text;
        Quantity : Int;
        Total : Float;
    };

    public type Sale = {
        CustomerId : Text;
        // Acá se almacena el listado de productos comprados
        Purchases : [ProductPurchase];
    };
};
