import { Paintbrush, Construction, Layers, Weight, Home, Droplets } from "lucide-react";
import { motion } from "framer-motion";

const products = [
  {
    icon: <Construction className="w-10 h-10 text-green-600" />,
    title: "Semen & Pasir",
    desc: "Sedia berbagai merk semen berkualitas dan pasir bersih untuk cor/pasang bata.",
  },
  {
    icon: <Paintbrush className="w-10 h-10 text-green-600" />,
    title: "Cat Tembok & Kayu",
    desc: "Pilihan warna lengkap untuk mempercantik rumah Anda, dalam maupun luar.",
  },
  {
    icon: <Weight className="w-10 h-10 text-green-600" />,
    title: "Besi Beton",
    desc: "Besi berbagai ukuran untuk pondasi bangunan yang kokoh dan tahan lama.",
  },
  {
    icon: <Layers className="w-10 h-10 text-green-600" />,
    title: "Genteng & Atap",
    desc: "Lindungi rumah dari hujan dan panas dengan pilihan atap yang awet.",
  },
  {
    icon: <Droplets className="w-10 h-10 text-green-600" />,
    title: "Pipa & Sanitari",
    desc: "Kebutuhan saluran air lengkap, mulai dari pipa PVC hingga kran air.",
  },
  {
    icon: <Home className="w-10 h-10 text-green-600" />,
    title: "Alat Pertukangan",
    desc: "Cangkul, palu, meteran, dan alat lainnya untuk memudahkan pekerjaan Anda.",
  },
];

export default function Features() {
  const card = {
    hidden: { opacity: 0, y: 16 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.4 } },
  };

  return (
    <section id="what-we-sell" className="bg-white py-24 sm:py-32">
      <div className="max-w-7xl mx-auto px-6">
        <div className="text-center mb-16">
          <h2 className="text-4xl font-black text-slate-900 tracking-tight mb-4">
            Katalog Material Bangunan Lengkap
          </h2>
          <p className="text-slate-500 text-lg">
            Semua kebutuhan bangun rumah Anda ada di Klampis Depo Surabaya.
          </p>
        </div>
        
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
          {products.map((p, i) => (
            <motion.div
              key={i}
              variants={card}
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, amount: 0.2 }}
              whileHover={{ y: -8 }}
              className="bg-white border border-slate-100 rounded-3xl p-8 shadow-sm hover:shadow-md hover:border-green-100 transition-all group"
            >
              <div className="mb-6 group-hover:scale-110 transition-transform duration-300">
                {p.icon}
              </div>
              <h3 className="font-bold text-2xl mb-3 text-slate-900">
                {p.title}
              </h3>
              <p className="text-slate-500 leading-relaxed">
                {p.desc}
              </p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
