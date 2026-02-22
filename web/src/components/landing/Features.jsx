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
    <section className="bg-white py-16">
      <div className="max-w-6xl mx-auto px-6">
        <h2 className="text-3xl font-bold text-center mb-12">
          Mengapa Memilih <span className="text-yellow-500">Klampis Depo</span>?
        </h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-8">
          {features.map((f, i) => (
            <motion.div
              key={i}
              variants={card}
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, amount: 0.2 }}
              whileHover={{ y: -6, scale: 1.02 }}
              transition={{ type: "spring", stiffness: 200, damping: 20 }}
              className="bg-yellow-50 border border-yellow-200 rounded-xl p-6 text-center shadow hover:shadow-lg"
            >
              <div className="flex justify-center mb-4">{f.icon}</div>
              <h3 className="font-semibold text-lg mb-2">{f.title}</h3>
              <p className="text-gray-600 text-sm">{f.desc}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
