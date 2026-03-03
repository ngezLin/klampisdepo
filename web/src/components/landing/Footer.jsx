import { motion } from "framer-motion";

export default function Footer() {
  return (
    <motion.footer
      className="bg-black text-gray-500 py-12 border-t border-white/5"
      initial={{ opacity: 0 }}
      whileInView={{ opacity: 1 }}
      viewport={{ once: true, amount: 0.2 }}
      transition={{ duration: 0.4 }}
    >
      <div className="max-w-7xl mx-auto px-6 flex flex-col md:flex-row justify-between items-center gap-6">
        <p className="text-sm">
          © {new Date().getFullYear()} KlampisDepo. Crafted for excellence.
        </p>
        <div className="space-x-4">
          <a
            href="https://wa.me/6285100549376"
            className="hover:text-white transition-colors"
          >
            WhatsApp
          </a>
          <a
            href="https://www.instagram.com/depoklampis/"
            className="hover:text-white transition-colors"
          >
            Instagram
          </a>
          <a
            href="https://www.tokopedia.com/klampisdepo"
            className="hover:text-white transition-colors"
          >
            Tokopedia
          </a>
        </div>
      </div>
    </motion.footer>
  );
}
