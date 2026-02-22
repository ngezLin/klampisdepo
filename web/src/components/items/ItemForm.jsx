import { useState, useEffect } from "react";
import toast from "react-hot-toast";

export default function ItemForm({
  isOpen,
  onClose,
  onSubmit,
  initialData,
  items = [],
}) {
  const [form, setForm] = useState({
    name: "",
    description: "",
    stock: 0,
    buy_price: 0,
    price: 0,
    image_url: "",
  });

  const [nameError, setNameError] = useState("");

  // Load initial data saat edit
  useEffect(() => {
    if (initialData) {
      setForm({
        ...initialData,
        image_url: initialData.image_url || "",
      });
    } else {
      setForm({
        name: "",
        description: "",
        stock: 0,
        buy_price: 0,
        price: 0,
        image_url: "",
      });
    }
    setNameError("");
  }, [initialData]);

  if (!isOpen) return null;

  // Handle input change
  const handleChange = (e) => {
    const { name, value, type } = e.target;
    const newValue = type === "number" ? Number(value) : value;

    setForm((prev) => ({
      ...prev,
      [name]: newValue,
    }));

    // Validasi nama duplikat realtime
    if (name === "name") {
      const duplicate = items.some(
        (i) =>
          i.name.toLowerCase() === newValue.toLowerCase() && i.id !== form.id
      );
      setNameError(duplicate ? "Nama item sudah ada!" : "");
    }
  };

  // Handle form submit
  const handleSubmit = (e) => {
    e.preventDefault();

    // Cek nama duplikat sebelum submit
    if (
      items.some(
        (i) =>
          i.name.toLowerCase() === form.name.toLowerCase() && i.id !== form.id
      )
    ) {
      toast("Nama item sudah ada! Silakan gunakan nama lain.");
      return;
    }

    // Kirim data ke parent component (Items.jsx)
    onSubmit(form);
    onClose();
  };

  return (
    <div className="fixed inset-0 flex items-center justify-center bg-black/50 z-50">
      <div className="bg-white p-6 rounded shadow-lg w-[400px]">
        <h2 className="text-lg font-bold mb-4">
          {initialData ? "Edit Item" : "Add Item"}
        </h2>
        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Name */}
          <div>
            <label className="block text-sm font-medium mb-1">Name</label>
            <input
              type="text"
              name="name"
              value={form.name}
              onChange={handleChange}
              className={`border p-2 w-full rounded ${
                nameError ? "border-red-500" : ""
              }`}
              required
            />
            {nameError && (
              <p className="text-red-600 text-sm mt-1">{nameError}</p>
            )}
          </div>

          {/* Description */}
          <div>
            <label className="block text-sm font-medium mb-1">
              Description
            </label>
            <textarea
              name="description"
              value={form.description || ""}
              onChange={handleChange}
              className="border p-2 w-full rounded"
            />
          </div>

          {/* Stock */}
          <div>
            <label className="block text-sm font-medium mb-1">Stock</label>
            <input
              type="number"
              name="stock"
              value={form.stock}
              onChange={handleChange}
              className="border p-2 w-full rounded"
              required
            />
          </div>

          {/* Buy Price */}
          <div>
            <label className="block text-sm font-medium mb-1">Buy Price</label>
            <input
              type="number"
              name="buy_price"
              value={form.buy_price}
              onChange={handleChange}
              className="border p-2 w-full rounded"
              required
            />
          </div>

          {/* Sell Price */}
          <div>
            <label className="block text-sm font-medium mb-1">Sell Price</label>
            <input
              type="number"
              name="price"
              value={form.price}
              onChange={handleChange}
              className="border p-2 w-full rounded"
              required
            />
          </div>

          {/* Image URL */}
          <div>
            <label className="block text-sm font-medium mb-1">Image URL</label>
            <input
              type="text"
              name="image_url"
              value={form.image_url}
              onChange={handleChange}
              placeholder="https://example.com/image.jpg"
              className="border p-2 w-full rounded"
            />
          </div>

          {/* Actions */}
          <div className="flex justify-end space-x-2 mt-4">
            <button
              type="button"
              onClick={onClose}
              className="bg-gray-400 text-white px-3 py-1 rounded"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="bg-blue-600 text-white px-3 py-1 rounded"
              disabled={!!nameError}
            >
              {initialData ? "Update" : "Save"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
