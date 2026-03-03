import { useState, useEffect, useRef } from "react";
import toast from "react-hot-toast";
import { uploadImage } from "../../services/itemService";
import { BASE_URL } from "../../services/api";
import { compressImage } from "../../utils/imageCompression";
import { motion, AnimatePresence } from "framer-motion";
import {
  X,
  Upload,
  Package,
  Info,
  DollarSign,
  Box,
  CheckCircle2,
  Camera,
  Link,
  Loader2,
} from "lucide-react";
import Input from "../common/Input";

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
  }, [initialData, isOpen]);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    const newValue =
      type === "checkbox" ? checked : type === "number" ? Number(value) : value;

    setForm((prev) => ({
      ...prev,
      [name]: newValue,
    }));

    if (name === "name") {
      const duplicate = items.some(
        (i) =>
          i.name.toLowerCase() === newValue.toLowerCase() && i.id !== form.id,
      );
      setNameError(duplicate ? "Nama item sudah ada!" : "");
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();

    if (isUploading) {
      toast("Sedang mengupload gambar, mohon tunggu.");
      return;
    }

    if (
      items.some(
        (i) =>
          i.name.toLowerCase() === form.name.toLowerCase() && i.id !== form.id,
      )
    ) {
      toast.error("Nama item sudah ada! Silakan gunakan nama lain.");
      return;
    }

    onSubmit(form);
    onClose();
  };

  const handleImageChange = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    if (!file.type.startsWith("image/")) {
      toast.error("Format file harus berupa gambar");
      return;
    }

    try {
      setIsUploading(true);
      const compressedFile = await compressImage(file, 800, 800, 0.7);
      const res = await uploadImage(compressedFile);

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
      if (fileInputRef.current) fileInputRef.current.value = "";
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="absolute inset-0 bg-black/60 backdrop-blur-sm"
          />

          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 20 }}
            className="relative w-full max-w-lg bg-[#121212]/90 backdrop-blur-2xl border border-white/10 rounded-[2.5rem] shadow-2xl overflow-hidden"
          >
            {/* Header */}
            <div className="px-8 pt-8 pb-4 flex items-center justify-between relative">
              <div className="flex items-center gap-3">
                <div className="p-3 bg-blue-500/10 rounded-2xl">
                  {initialData ? (
                    <Box className="w-6 h-6 text-blue-500" />
                  ) : (
                    <Package className="w-6 h-6 text-blue-500" />
                  )}
                </div>
                <div>
                  <h2 className="text-xl font-bold text-white leading-tight">
                    {initialData ? "Update Item" : "New Inventory Item"}
                  </h2>
                  <p className="text-xs text-gray-500 font-medium tracking-wide font-['Inter']">
                    {initialData
                      ? "MODAL_V2 // UPDATE_EXISTING"
                      : "MODAL_V2 // CREATE_NEW"}
                  </p>
                </div>
              </div>
              <button
                onClick={onClose}
                className="p-2 hover:bg-white/5 rounded-xl transition-colors group"
              >
                <X className="w-5 h-5 text-gray-400 group-hover:text-white" />
              </button>

              {/* Top Accent Line */}
              <div className="absolute top-0 left-12 right-12 h-[1px] bg-gradient-to-r from-transparent via-blue-500/50 to-transparent" />
            </div>

            <form
              onSubmit={handleSubmit}
              className="px-8 pb-8 space-y-6 max-h-[80vh] overflow-y-auto custom-scrollbar"
            >
              <div className="grid grid-cols-1 gap-5 pt-2">
                {/* Basic Info */}
                <Input
                  label="Item Name"
                  name="name"
                  icon={Package}
                  value={form.name}
                  onChange={handleChange}
                  error={nameError}
                  placeholder="e.g. Premium Motor Oil"
                  required
                />

                <div className="space-y-1.5">
                  <label className="block text-sm font-semibold text-gray-300 ml-1 flex items-center gap-2">
                    <Info className="w-3.5 h-3.5" /> Description
                  </label>
                  <textarea
                    name="description"
                    value={form.description || ""}
                    onChange={handleChange}
                    rows={3}
                    placeholder="Briefly describe the item features and specifications..."
                    className="block w-full px-4 py-3 bg-white/5 border border-white/10 rounded-2xl text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-500/50 transition-all text-sm font-medium resize-none"
                  />
                </div>

                {/* Stock Management */}
                <div className="flex items-center gap-4 bg-white/5 p-4 rounded-3xl border border-white/5">
                  <div className="flex-1 space-y-1">
                    <label className="text-sm font-bold text-white flex items-center gap-2">
                      <Box className="w-4 h-4 text-orange-500" /> Kelola Stok
                    </label>
                    <p className="text-[10px] text-gray-500 font-medium">
                      Aktifkan untuk memantau inventori secara real-time
                    </p>
                  </div>
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input
                      type="checkbox"
                      name="is_stock_managed"
                      checked={form.is_stock_managed}
                      onChange={handleChange}
                      className="sr-only peer"
                    />
                    <div className="w-11 h-6 bg-white/10 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-gray-400 after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-orange-600 peer-checked:after:bg-white"></div>
                  </label>
                </div>

                <AnimatePresence>
                  {form.is_stock_managed && (
                    <motion.div
                      initial={{ opacity: 0, height: 0 }}
                      animate={{ opacity: 1, height: "auto" }}
                      exit={{ opacity: 0, height: 0 }}
                      className="overflow-hidden"
                    >
                      <Input
                        label="Current Stock"
                        name="stock"
                        type="number"
                        icon={Box}
                        value={form.stock}
                        onChange={handleChange}
                        placeholder="0"
                        required
                      />
                    </motion.div>
                  )}
                </AnimatePresence>

                {/* Pricing Grid */}
                <div className="grid grid-cols-2 gap-4">
                  <Input
                    label="Buy Price"
                    name="buy_price"
                    type="number"
                    icon={DollarSign}
                    value={form.buy_price}
                    onChange={handleChange}
                    placeholder="0"
                    required
                  />
                  <Input
                    label="Sale Price"
                    name="price"
                    type="number"
                    icon={DollarSign}
                    value={form.price}
                    onChange={handleChange}
                    placeholder="0"
                    required
                  />
                </div>

                {/* Image Section */}
                <div className="space-y-3">
                  <label className="block text-sm font-semibold text-gray-300 ml-1">
                    Item Appearance
                  </label>
                  <div className="flex flex-col gap-4">
                    {/* Image Preview / Dropzone */}
                    <div className="relative group overflow-hidden bg-white/5 border-2 border-dashed border-white/10 rounded-[2rem] hover:border-blue-500/50 transition-all duration-300 min-h-[160px] flex items-center justify-center">
                      {form.image_url ? (
                        <div className="absolute inset-0 z-0">
                          <img
                            src={
                              String(form.image_url).startsWith("http")
                                ? form.image_url
                                : `${BASE_URL}${form.image_url}`
                            }
                            alt="Preview"
                            className="w-full h-full object-cover transition-transform group-hover:scale-110 duration-700"
                          />
                          <div className="absolute inset-0 bg-black/40 backdrop-blur-[2px]" />
                        </div>
                      ) : null}

                      <div className="relative z-10 flex flex-col items-center text-center px-6">
                        {form.image_url ? (
                          <>
                            <div className="w-12 h-12 bg-green-500/20 rounded-2xl flex items-center justify-center mb-2 animate-bounce">
                              <CheckCircle2 className="w-6 h-6 text-green-500" />
                            </div>
                            <p className="text-white text-sm font-bold">
                              Image Ready
                            </p>
                            <button
                              type="button"
                              onClick={() =>
                                setForm((p) => ({ ...p, image_url: "" }))
                              }
                              className="mt-2 text-[10px] text-red-400 font-bold uppercase tracking-widest hover:text-red-300 underline underline-offset-4"
                            >
                              Remove Image
                            </button>
                          </>
                        ) : (
                          <>
                            <div className="w-14 h-14 bg-white/5 rounded-2xl flex items-center justify-center mb-3 group-hover:bg-blue-600/20 group-hover:scale-110 transition-all">
                              <Camera className="w-7 h-7 text-gray-400 group-hover:text-blue-500" />
                            </div>
                            <p className="text-gray-400 text-sm font-medium">
                              Take a Photo or{" "}
                              <span className="text-blue-500 underline font-bold">
                                Browse
                              </span>
                            </p>
                            <p className="text-[10px] text-gray-500 mt-1 uppercase font-bold tracking-tighter">
                              Max 2MB // JPG, PNG, WEBP
                            </p>
                          </>
                        )}
                      </div>

                      <input
                        type="file"
                        accept="image/*"
                        capture="environment"
                        ref={fileInputRef}
                        onChange={handleImageChange}
                        disabled={isUploading}
                        className="absolute inset-0 opacity-0 cursor-pointer"
                      />

                      {isUploading && (
                        <div className="absolute inset-0 bg-black/60 backdrop-blur-md flex flex-col items-center justify-center z-20">
                          <Loader2 className="w-10 h-10 text-blue-500 animate-spin mb-2" />
                          <p className="text-white text-xs font-bold animate-pulse">
                            Processing Image...
                          </p>
                        </div>
                      )}
                    </div>

                    <div className="flex items-center gap-3">
                      <div className="flex-1 relative">
                        <Input
                          icon={Link}
                          name="image_url"
                          value={form.image_url}
                          onChange={handleChange}
                          placeholder="Or paste link: https://..."
                          className="!py-2 !text-xs"
                        />
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex gap-3 pt-4">
                <button
                  type="button"
                  onClick={onClose}
                  className="flex-1 py-4 px-6 rounded-2xl bg-white/5 text-gray-400 font-bold text-sm hover:bg-white/10 hover:text-white transition-all border border-white/5 active:scale-95"
                >
                  Discard
                </button>
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  type="submit"
                  disabled={!!nameError || isUploading}
                  className="flex-[2] py-4 px-6 rounded-2xl bg-gradient-to-r from-blue-600 to-indigo-600 text-white font-bold text-sm shadow-lg shadow-blue-500/25 disabled:opacity-50 disabled:cursor-not-allowed transition-all relative overflow-hidden group"
                >
                  <div className="absolute inset-0 bg-white/20 opacity-0 group-hover:opacity-100 transition-opacity" />
                  <span className="relative flex items-center justify-center gap-2">
                    {initialData ? (
                      <>
                        <Box className="w-4 h-4" /> Update Inventory
                      </>
                    ) : (
                      <>
                        <CheckCircle2 className="w-4 h-4" /> Save Item
                      </>
                    )}
                  </span>
                </motion.button>
              </div>
            </form>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
}
