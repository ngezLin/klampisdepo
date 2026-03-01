import { useState } from "react";
import { View, Text, TextInput, TouchableOpacity, Alert } from "react-native";
import { createItem, updateItem } from "../../services/items.service";

export default function ItemForm({ route, navigation }: any) {
  const item = route?.params?.item;

  const [name, setName] = useState(item?.name || "");
  const [stock, setStock] = useState(String(item?.stock || ""));
  const [price, setPrice] = useState(String(item?.price || ""));
  const [buy_price, setBuyPrice] = useState(String(item?.buy_price || ""));
  const [description, setDescription] = useState(item?.description || "");

  const handleSubmit = async () => {
    if (!name || !stock || !price) {
      Alert.alert("Error", "Semua field wajib diisi");
      return;
    }

    const payload = {
      name,
      stock: Number(stock),
      price: Number(price),
      buy_price: Number(buy_price),
      description: description,
    };

    try {
      if (item) {
        await updateItem(item.id, payload);
      } else {
        await createItem(payload);
      }
      navigation.goBack();
    } catch (err) {
      console.log(err);
    }
  };

  return (
    <View style={{ padding: 16 }}>
      <Text style={{ fontSize: 18, marginBottom: 10 }}>
        {item ? "Edit Item" : "Tambah Item"}
      </Text>

      <TextInput
        placeholder="Nama"
        value={name}
        onChangeText={setName}
        style={{ borderWidth: 1, marginBottom: 10 }}
      />

      <TextInput
        placeholder="Stock"
        keyboardType="numeric"
        value={stock}
        onChangeText={setStock}
        style={{ borderWidth: 1, marginBottom: 10 }}
      />

      <TextInput
        placeholder="SKU"
        value={description}
        onChangeText={setDescription}
        style={{ borderWidth: 1, marginBottom: 20 }}
      />

      <TextInput
        placeholder="Price"
        keyboardType="numeric"
        value={price}
        onChangeText={setPrice}
        style={{ borderWidth: 1, marginBottom: 20 }}
      />
      <TextInput
        placeholder="Buy Price"
        keyboardType="numeric"
        value={buy_price}
        onChangeText={setPrice}
        style={{ borderWidth: 1, marginBottom: 20 }}
      />

      <TouchableOpacity
        onPress={handleSubmit}
        style={{
          backgroundColor: "#2563eb",
          padding: 14,
          borderRadius: 6,
          alignItems: "center",
        }}
      >
        <Text style={{ color: "#fff" }}>SIMPAN</Text>
      </TouchableOpacity>
    </View>
  );
}
