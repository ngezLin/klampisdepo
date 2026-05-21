import { motion } from "framer-motion";
import { MessageCircle, ShoppingBag } from "lucide-react";

export default function CTASection() {
  return (
    <section className="bg-green-600 py-20 overflow-hidden relative">
      {/* Decorative circles */}
      <div className="absolute top-0 right-0 w-96 h-96 bg-white/10 rounded-full blur-3xl -mr-48 -mt-48"></div>
      <div className="absolute bottom-0 left-0 w-96 h-96 bg-black/10 rounded-full blur-3xl -ml-48 -mb-48"></div>

      <div className="max-w-4xl mx-auto px-6 relative z-10 text-center text-white">
        <motion.h2 
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          className="text-4xl md:text-5xl font-black mb-6 tracking-tight"
        >
          Butuh Bahan Bangunan di Surabaya?
        </motion.h2>
        <motion.p 
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="text-xl text-green-100 mb-10 max-w-2xl mx-auto leading-relaxed"
        >
          Langsung chat admin kami atau mampir ke Tokopedia kami. Stok selalu ready, harga bersaing!
        </motion.p>

        <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
          <motion.a
            href="https://wa.me/6281234567890" // Placeholder
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className="flex items-center gap-3 bg-white text-green-600 px-8 py-4 rounded-2xl font-bold text-lg shadow-xl hover:shadow-2xl transition-all w-full sm:w-auto justify-center"
          >
            <MessageCircle className="w-6 h-6" />
            Chat via WhatsApp
          </motion.a>
          
          <motion.a
            href="https://www.tokopedia.com" // Placeholder
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className="flex items-center gap-3 bg-black/20 border-2 border-white/20 backdrop-blur-sm text-white px-8 py-4 rounded-2xl font-bold text-lg hover:bg-black/30 transition-all w-full sm:w-auto justify-center"
          >
            <ShoppingBag className="w-6 h-6" />
            Beli di Tokopedia
          </motion.a>
        </div>
      </div>
    </section>
  );
}
