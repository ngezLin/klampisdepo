import { motion } from "framer-motion";
import { BASE_URL } from "../../services/api";

export default function ProductCard({ item }) {
  const placeholder =
    "https://lh5.googleusercontent.com/proxy/211Ca3xFzqt_aKp8B3LjO8T7etZyEKVXv2NN4wHJDIH0ZmcGBWKho21SCa19Bh6AmanXwC3MeP3mmaiWcGkFV_mDYZLhZ0UszlBVMLo7eGRvXXgnFAr9mvAJe6czDTPMKU-ja5rX0ItRgR2tpK077vt5yOV6ottZGMon2A=w160-h120-k-no";

  return (
    <motion.div
      whileHover={{ y: -12, scale: 1.02 }}
      transition={{ type: "spring", stiffness: 300, damping: 20 }}
      className="group bg-gray-900/40 backdrop-blur-md rounded-3xl overflow-hidden border border-white/5 hover:border-blue-500/30 transition-all duration-300 shadow-xl hover:shadow-blue-500/10"
      role="article"
      aria-label={item?.name || "Produk"}
    >
      <div className="relative overflow-hidden">
        <img
          src={
            item?.image_url
              ? String(item?.image_url).startsWith("http")
                ? item.image_url
                : `${BASE_URL}${item.image_url}`
              : placeholder
          }
          alt={item?.name || "Produk"}
          className="w-full h-48 object-cover transition-transform duration-500 group-hover:scale-110"
        />
        {/* subtle overlay on hover */}
        <div className="pointer-events-none absolute inset-0 bg-black/0 group-hover:bg-black/10 transition-colors duration-300" />
      </div>
      <div className="p-6">
        <h3 className="font-bold text-xl mb-2 text-white line-clamp-1 group-hover:text-blue-400 transition-colors">
          {item?.name}
        </h3>
        <p className="text-gray-400 text-sm mb-4 line-clamp-2 leading-relaxed h-10">
          {item?.description || "Deskripsi tidak tersedia."}
        </p>
        <p className="font-bold text-blue-400 text-2xl tracking-tight">
          Rp {(item?.price ?? 0).toLocaleString("id-ID")}
        </p>
      </div>
    </motion.div>
  );
}
