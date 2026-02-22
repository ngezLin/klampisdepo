import { motion } from "framer-motion";

export default function Footer() {
  return (
    <motion.footer
      className="bg-gray-900 text-gray-400 py-6 mt-10"
      initial={{ opacity: 0 }}
      whileInView={{ opacity: 1 }}
      viewport={{ once: true, amount: 0.2 }}
      transition={{ duration: 0.4 }}
    >
      <div className="max-w-6xl mx-auto px-6 flex justify-between items-center">
        <p>© {new Date().getFullYear()} KD System. All rights reserved.</p>
        <div className="space-x-4">
          <a href="https://wa.me/6285100549376" className="hover:text-white">
            whatsapp
          </a>
          <a
            href="https://www.instagram.com/depoklampis/"
            className="hover:text-white"
          >
            Instagram
          </a>
          <a
            href="https://www.tokopedia.com/klampisdepo"
            className="hover:text-white"
          >
            Tokopedia
          </a>
        </div>
      </div>
    </motion.footer>
  );
}
