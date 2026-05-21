import bgImage from "../../assets/asset2.png";
import { motion } from "framer-motion";

export default function MapSection() {
  const fadeUp = {
    hidden: { opacity: 0, y: 18 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.45 } },
  };

  return (
    <section
      className="relative py-16"
      style={{
        backgroundImage: `url(${bgImage})`,
        backgroundSize: "cover",
        backgroundPosition: "center",
      }}
    >
      <div className="absolute inset-0 bg-white/90 backdrop-blur-sm"></div>
      <div className="relative max-w-6xl mx-auto px-6 text-center">
        <motion.h2
          className="text-4xl font-black mb-6 text-slate-900 tracking-tight"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.2 }}
          variants={fadeUp}
        >
          Mampir ke <span className="text-green-600">Toko Kami</span>
        </motion.h2>
        <motion.p
          className="text-slate-500 mb-12 text-lg max-w-2xl mx-auto"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.2 }}
          variants={fadeUp}
        >
          Lebih enak kalau lihat barangnya langsung. Datang saja ke UD. Klampis Depo di Jl. Klampis Harapan No. G-168, Surabaya. Kami buka setiap hari!
        </motion.p>
        <motion.div
          className="rounded-3xl overflow-hidden shadow-2xl border border-slate-200 max-w-5xl mx-auto"
          initial={{ opacity: 0, scale: 0.98 }}
          whileInView={{ opacity: 1, scale: 1 }}
          viewport={{ once: true, amount: 0.2 }}
          transition={{ duration: 0.5 }}
          whileHover={{ scale: 1.005 }}
        >
          <iframe
            src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3958.125332253869!2d112.7793589!3d-7.2952918!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x2dd7fa5b4b0bfce1%3A0xa07b8b8602f4a3db!2sUD.%20Klampis%20Depo!5e0!3m2!1sen!2sid!4v1692960721066!5m2!1sen!2sid"
            width="100%"
            height="450"
            style={{
              border: 0,
            }}
            allowFullScreen=""
            loading="lazy"
            title="Google Maps"
          ></iframe>
        </motion.div>
      </div>
    </section>
  );
}
