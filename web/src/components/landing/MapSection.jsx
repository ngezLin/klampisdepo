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
      <div className="absolute inset-0 bg-yellow-100/80"></div>
      <div className="relative max-w-6xl mx-auto px-6 text-center">
        <motion.h2
          className="text-3xl font-bold mb-6"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.2 }}
          variants={fadeUp}
        >
          Temukan <span className="text-blue-800">Lokasi Kami</span>
        </motion.h2>
        <motion.p
          className="text-gray-700 mb-8"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.2 }}
          variants={fadeUp}
        >
          Kunjungi toko fisik kami untuk pengalaman belanja langsung.
        </motion.p>
        <motion.div
          className="rounded-xl overflow-hidden shadow-lg"
          initial={{ opacity: 0, scale: 0.98 }}
          whileInView={{ opacity: 1, scale: 1 }}
          viewport={{ once: true, amount: 0.2 }}
          transition={{ duration: 0.5 }}
          whileHover={{ scale: 1.01 }}
        >
          <iframe
            src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3958.125332253869!2d112.7793589!3d-7.2952918!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x2dd7fa5b4b0bfce1%3A0xa07b8b8602f4a3db!2sUD.%20Klampis%20Depo!5e0!3m2!1sen!2sid!4v1692960721066!5m2!1sen!2sid"
            width="100%"
            height="400"
            style={{ border: 0 }}
            allowFullScreen=""
            loading="lazy"
            title="Google Maps"
          ></iframe>
        </motion.div>
      </div>
    </section>
  );
}
