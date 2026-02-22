import { motion } from "framer-motion";

export default function ProductCard({ item }) {
  const placeholder =
    "https://lh5.googleusercontent.com/proxy/211Ca3xFzqt_aKp8B3LjO8T7etZyEKVXv2NN4wHJDIH0ZmcGBWKho21SCa19Bh6AmanXwC3MeP3mmaiWcGkFV_mDYZLhZ0UszlBVMLo7eGRvXXgnFAr9mvAJe6czDTPMKU-ja5rX0ItRgR2tpK077vt5yOV6ottZGMon2A=w160-h120-k-no";

  return (
    <motion.div
      whileHover={{ y: -8, scale: 1.02 }}
      transition={{ type: "spring", stiffness: 300, damping: 20 }}
      className="group bg-white shadow-md rounded-xl overflow-hidden transform transition duration-300 hover:shadow-2xl"
      role="article"
      aria-label={item?.name || "Produk"}
    >
      <div className="relative overflow-hidden">
        <img
          src={item?.image_url || placeholder}
          alt={item?.name || "Produk"}
          className="w-full h-48 object-cover transition-transform duration-500 group-hover:scale-110"
        />
        {/* subtle overlay on hover */}
        <div className="pointer-events-none absolute inset-0 bg-black/0 group-hover:bg-black/10 transition-colors duration-300" />
      </div>
      <div className="p-4">
        <h3 className="font-semibold text-lg mb-2 line-clamp-1">
          {item?.name}
        </h3>
        <p className="text-gray-600 text-sm mb-3 line-clamp-2">
          {item?.description || "Deskripsi tidak tersedia."}
        </p>
        <p className="font-bold text-blue-800 text-lg">
          Rp {(item?.price ?? 0).toLocaleString()}
        </p>
      </div>
    </motion.div>
  );
}
