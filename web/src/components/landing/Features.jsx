import { Truck, ShieldCheck, Zap, Headphones, Store } from "lucide-react";
import { motion } from "framer-motion";

const features = [
  {
    icon: <Truck className="w-10 h-10 text-yellow-500" />,
    title: "Ongkir Murah",
    desc: "Nikmati pengiriman hemat ke seluruh Indonesia.",
  },
  {
    icon: <Store className="w-10 h-10 text-yellow-500" />,
    title: "Support Tokopedia",
    desc: "Belanja juga via Tokopedia / offline store dengan aman.",
  },
  {
    icon: <ShieldCheck className="w-10 h-10 text-yellow-500" />,
    title: "Transaksi Aman",
    desc: "Pembayaran & data bisa menggunakan transfer, qris, cash, dll.",
  },
  // {
  //   icon: <Gift className="w-10 h-10 text-yellow-500" />,
  //   title: "Point & Reward",
  //   desc: "Dapatkan poin setiap belanja untuk reward menarik.",
  // },
  {
    icon: <Zap className="w-10 h-10 text-yellow-500" />,
    title: "Pengiriman Cepat",
    desc: "Pesanan dikirim dalam waktu singkat.",
  },
  {
    icon: <Headphones className="w-10 h-10 text-yellow-500" />,
    title: "Hubungi kami",
    desc: "Customer Service siap membantu Anda kapan saja.",
  },
  {
    icon: <Truck className="w-10 h-10 text-yellow-500" />,
    title: "Ongkir Murah",
    desc: "Sedia pickup sebelum hujan.",
  },
];

export default function Features() {
  const card = {
    hidden: { opacity: 0, y: 16 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.4 } },
  };

  return (
    <section className="bg-black py-24 sm:py-32">
      <div className="max-w-6xl mx-auto px-6">
        <h2 className="text-4xl font-bold text-center mb-16 text-white tracking-tight">
          Mengapa Memilih{" "}
          <span className="text-transparent bg-clip-text bg-gradient-to-r from-yellow-400 to-orange-500">
            Klampis Depo
          </span>
          ?
        </h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-8">
          {features.map((f, i) => (
            <motion.div
              key={i}
              variants={card}
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, amount: 0.2 }}
              whileHover={{ y: -8, scale: 1.02 }}
              transition={{ type: "spring", stiffness: 200, damping: 20 }}
              className="bg-gray-900/40 backdrop-blur-md border border-white/5 rounded-3xl p-8 text-center shadow-2xl hover:bg-gray-800/60 transition-all group"
            >
              <div className="flex justify-center mb-6 group-hover:scale-110 transition-transform duration-300">
                {f.icon}
              </div>
              <h3 className="font-bold text-xl mb-3 text-white tracking-tight">
                {f.title}
              </h3>
              <p className="text-gray-400 text-sm leading-relaxed">{f.desc}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
