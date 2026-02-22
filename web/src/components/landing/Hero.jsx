import { Link } from "react-router-dom";
import bgImage from "../../assets/asset1.png"; // ✅ import
import { motion } from "framer-motion"; // ✅ add framer-motion for staggered entrance and subtle float

export default function Hero() {
  const container = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: { staggerChildren: 0.15 },
    },
  };
  const itemUp = {
    hidden: { opacity: 0, y: 24 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.5 } },
  };

  return (
    <section
      className="relative bg-yellow-400 text-gray-900 py-20 text-center"
      style={{
        backgroundImage: `url(${bgImage})`,
        backgroundSize: "cover",
        backgroundPosition: "center",
      }}
    >
      <div className="absolute inset-0 bg-yellow-400/70"></div>
      <motion.div
        className="relative max-w-4xl mx-auto px-6"
        initial="hidden"
        animate="visible"
        variants={container}
      >
        <motion.h1
          variants={itemUp}
          className="text-5xl md:text-6xl font-extrabold mb-6 leading-tight"
        >
          Selamat Datang di <span className="text-blue-800">Klampis Depo</span>
        </motion.h1>
        <motion.p
          variants={itemUp}
          className="text-lg md:text-xl mb-4 opacity-90"
        >
          Belanja kebutuhan retail Anda dengan <b>mudah</b> &{" "}
          <b>hemat ongkir</b>.
        </motion.p>
        <motion.p
          variants={itemUp}
          className="text-lg md:text-xl mb-8 opacity-90"
        >
          Di toko offline & online kami menyediakan berbagai kebutuhan retail
          pilihan dengan pelayanan cepat dan terpercaya. Kunjungi kami di Jl.
          Deles, Surabaya.
        </motion.p>
        <motion.div variants={itemUp} className="space-x-4">
          <Link
            to="/login"
            className="px-8 py-3 bg-blue-800 text-white font-semibold rounded-full shadow-lg hover:bg-blue-700 transition"
          >
            Login
          </Link>
          <a
            href="https://www.tokopedia.com/klampisdepo"
            target="_blank"
            rel="noopener noreferrer"
            className="px-8 py-3 bg-white text-blue-800 font-semibold rounded-full shadow-lg hover:bg-gray-100 transition"
          >
            Tokopedia
          </a>
        </motion.div>
      </motion.div>
    </section>
  );
}
