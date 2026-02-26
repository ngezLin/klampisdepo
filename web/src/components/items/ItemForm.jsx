import { useState, useEffect, useRef } from "react";
import toast from "react-hot-toast";
import { uploadImage } from "../../services/itemService";
import { compressImage } from "../../utils/imageCompression";

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
    is_stock_managed: true,
    buy_price: 0,
    price: 0,
    image_url: "",
  });

  const [nameError, setNameError] = useState("");
  const [isUploading, setIsUploading] = useState(false);
  const fileInputRef = useRef(null);

  // Load initial data saat edit
  useEffect(() => {
    if (initialData) {
      setForm({
        ...initialData,
        image_url: initialData.image_url || "",
        is_stock_managed:
          initialData.is_stock_managed !== undefined
            ? initialData.is_stock_managed
            : true,
      });
    } else {
      setForm({
        name: "",
        description: "",
        stock: 0,
        is_stock_managed: true,
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
    const { name, value, type, checked } = e.target;
    const newValue =
      type === "checkbox" ? checked : type === "number" ? Number(value) : value;

    setForm((prev) => ({
      ...prev,
      [name]: newValue,
    }));

    // Validasi nama duplikat realtime
    if (name === "name") {
      const duplicate = items.some(
        (i) =>
          i.name.toLowerCase() === newValue.toLowerCase() && i.id !== form.id,
      );
      setNameError(duplicate ? "Nama item sudah ada!" : "");
    }
  };

  // Handle form submit
  const handleSubmit = (e) => {
    e.preventDefault();

    if (isUploading) {
      toast("Sedang mengupload gambar, mohon tunggu.");
      return;
    }

    // Cek nama duplikat sebelum submit
    if (
      items.some(
        (i) =>
          i.name.toLowerCase() === form.name.toLowerCase() && i.id !== form.id,
      )
    ) {
      toast("Nama item sudah ada! Silakan gunakan nama lain.");
      return;
    }

    // Kirim data ke parent component (Items.jsx)
    onSubmit(form);
    onClose();
  };

  // Handle File Input for Image Upload
  const handleImageChange = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    if (!file.type.startsWith("image/")) {
      toast.error("Format file harus berupa gambar");
      return;
    }

    try {
      setIsUploading(true);
      // Compress Image
      const compressedFile = await compressImage(file, 800, 800, 0.7);

      // Upload directly to API
      const res = await uploadImage(compressedFile);

      // Assume API returns { url: "/uploads/..." }
      if (res && res.url) {
        setForm((prev) => ({
          ...prev,
          image_url: res.url,
        }));
        toast.success("Gambar berhasil di-upload!");
      } else {
        throw new Error("Invalid response format from server");
      }
    } catch (err) {
      console.error("Image upload error:", err);
      toast.error("Gagal mengupload gambar");
    } finally {
      setIsUploading(false);
      // Reset input value so same file can be selected again if needed
      if (fileInputRef.current) fileInputRef.current.value = "";
    }
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

          {/* Stock Management Form Field & Stock Input */}
          <div className="flex gap-4 mb-2 items-center">
            {/* Is Managed Stock */}
            <div className="flex flex-col flex-1">
              <label className="block text-sm font-medium mb-1">
                Kelola Stok?
              </label>
              <div className="flex items-center mt-2 h-[42px]">
                <label className="inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    name="is_stock_managed"
                    checked={form.is_stock_managed}
                    onChange={handleChange}
                    className="sr-only peer"
                  />
                  <div className="relative w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                  <span className="ms-3 text-sm font-medium text-gray-900">
                    {form.is_stock_managed ? "Ya" : "Tidak"}
                  </span>
                </label>
              </div>
            </div>

            {/* Stock */}
            <div className="flex-1">
              <label className="block text-sm font-medium mb-1">Stock</label>
              <input
                type="number"
                name="stock"
                value={form.is_stock_managed ? form.stock : ""}
                onChange={handleChange}
                placeholder={form.is_stock_managed ? "0" : "-"}
                disabled={!form.is_stock_managed}
                className="border p-2 w-full rounded disabled:bg-gray-100 disabled:text-gray-400"
                required={form.is_stock_managed}
              />
            </div>
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

          {/* Image Upload */}
          <div>
            <label className="block text-sm font-medium mb-1">
              Image / Photo
            </label>
            <div className="flex items-center gap-4">
              {form.image_url ? (
                <div className="relative w-20 h-20 border rounded overflow-hidden flex-shrink-0 bg-gray-50">
                  <img
                    src={
                      String(form.image_url).startsWith("http")
                        ? form.image_url
                        : `${process.env.REACT_APP_API_URL || "http://localhost:8080"}${form.image_url}`
                    }
                    alt="Preview"
                    className="w-full h-full object-cover"
                  />
                  <button
                    type="button"
                    className="absolute top-0 right-0 bg-red-600/80 text-white rounded-bl text-xs px-1 hover:bg-red-700"
                    onClick={() => setForm((p) => ({ ...p, image_url: "" }))}
                  >
                    x
                  </button>
                </div>
              ) : (
                <div className="w-20 h-20 border-2 border-dashed border-gray-300 rounded flex items-center justify-center text-gray-400 text-xs text-center p-2 flex-shrink-0 bg-gray-50">
                  No Image
                </div>
              )}

              <div className="flex-1 flex flex-col gap-2">
                <input
                  type="file"
                  accept="image/*"
                  // Use "environment" pointing outward on mobile devices
                  capture="environment"
                  ref={fileInputRef}
                  onChange={handleImageChange}
                  disabled={isUploading}
                  className="block w-full text-sm text-gray-900 border border-gray-300 rounded-lg cursor-pointer bg-gray-50 focus:outline-none file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100"
                />

                <div className="flex items-center gap-2 w-full">
                  <span className="text-xs text-gray-500 font-medium">
                    ATAU
                  </span>
                  <input
                    type="text"
                    name="image_url"
                    value={form.image_url}
                    onChange={handleChange}
                    placeholder="Paste link gambar (https://...)"
                    className="flex-1 border p-1.5 text-sm rounded bg-white disabled:bg-gray-100 pointer-events-auto"
                  />
                </div>

                <p className="text-xs text-gray-500">
                  {isUploading
                    ? "Mengkompresi & Uploading..."
                    : "Pilih file / ambil foto, atau paste link."}
                </p>
              </div>
            </div>
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
              className={`px-3 py-1 rounded text-white ${!!nameError || isUploading ? "bg-blue-300" : "bg-blue-600 hover:bg-blue-700"}`}
              disabled={!!nameError || isUploading}
            >
              {isUploading ? "Uploading..." : initialData ? "Update" : "Save"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
