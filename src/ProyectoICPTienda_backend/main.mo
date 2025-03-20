import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Iter "mo:base/Iter";

actor {

  public query func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };

  /**
  ==============================
  ====  Inventory section  =====
  ==============================
  */

  type Product = {
    Name : Text;
    Quantity : Int;
    Price : Float;
  };
  stable var producId : Nat = 0;

  // Inicializar el HashMap correctamente
  let products = HashMap.HashMap<Text, Product>(0, Text.equal, Text.hash);

  // Función pública para agregar un producto
  public func AddProduct(product : Product) : async Text {
    let newId = generateProductId(); // Genera un nuevo ID único para el producto
    products.put(newId, product); // Agrega el producto a la lista
    return newId; // Devuelve el ID generado
  };

  private func generateProductId() : Text {
    producId += 1;
    return Nat.toText(producId);
  };

  public query func getProduct(key : Text) : async ?Product {
    products.get(key);
  };

  public query func getProducts() : async [(Text, Product)] {
    let producIter : Iter.Iter<(Text, Product)> = products.entries();
    Iter.toArray(producIter);
  };

  public func UpdateProduct(productId : Text, updatedProduct : Product) : async Bool {
    switch (products.get(productId)) {
      case (?existingProduct) {
        // Actualizamos el producto
        products.put(productId, updatedProduct);
        return true;
      };
      case (_) {
        // Producto no encontrado
        return false;
      };
    };
  };

  public func DeleteProduct(productId : Text) : async Bool {
    switch (products.remove(productId)) {
      case (?product) {
        // Producto eliminado con éxito
        return true;
      };
      case (_) {
        // Producto no encontrado
        return false;
      };
    };
  };

};
