import { useState } from "react";
import { motion } from "framer-motion";
import ProductCard from "./ProductCard";

export default function ProductList({ items }) {
  const [search, setSearch] = useState("");

  const filteredItems = items.filter((item) =>
    item.name.toLowerCase().includes(search.toLowerCase()),
  );

  const container = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: { staggerChildren: 0.08, delayChildren: 0.1 },
    },
  };
  const itemVar = {
    hidden: { opacity: 0, y: 18 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.4 } },
  };

  return (
    <section className="max-w-7xl mx-auto px-6 py-24 sm:py-32">
      <h2 className="text-4xl font-bold mb-12 text-center text-white tracking-tight">
        Produk{" "}
        <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-purple-400">
          Terbaru
        </span>
      </h2>

      <div className="flex justify-center mb-8">
        {/* motion input for subtle focus scale */}
        <motion.input
          type="text"
          placeholder="Cari produk kebanggaan..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          whileFocus={{
            scale: 1.02,
            boxShadow: "0 0 20px rgba(59, 130, 246, 0.2)",
          }}
          transition={{ type: "spring", stiffness: 250, damping: 18 }}
          className="w-full max-w-lg px-6 py-4 bg-gray-900 border-white/10 border rounded-2xl text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500/50 transition-all font-medium"
          aria-label="Cari produk"
        />
      </div>

      {filteredItems.length === 0 ? (
        <p className="text-center text-gray-500 py-20 italic text-lg">
          Produk tidak tersedia saat ini.
        </p>
      ) : (
        <motion.div
          variants={container}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.15 }}
          className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-8"
        >
          {filteredItems.map((item) => (
            <motion.div key={item.id} variants={itemVar}>
              <ProductCard item={item} />
            </motion.div>
          ))}
        </motion.div>
      )}
    </section>
  );
}
