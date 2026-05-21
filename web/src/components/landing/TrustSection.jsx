import { motion } from "framer-motion";
import { Truck, MessageSquare, Store, Tag } from "lucide-react";

const trustPoints = [
  {
    icon: <Tag className="w-8 h-8 text-green-600" />,
    title: "Harga Jujur & Murah",
    desc: "Stok barang selalu ready dengan harga yang kompetitif, jujur, dan tanpa biaya tersembunyi.",
  },
  {
    icon: <Truck className="w-8 h-8 text-green-600" />,
    title: "Pengiriman Hari Sama",
    desc: "Kirim barang berat ke lokasi Anda di Surabaya di hari yang sama dengan armada sendiri.",
  },
  {
    icon: <Store className="w-8 h-8 text-green-600" />,
    title: "Toko Fisik Jelas",
    desc: "Kami punya toko fisik di Surabaya. Bisa bayar via Transfer, QRIS, atau Cash saat barang sampai.",
  },
  {
    icon: <MessageSquare className="w-8 h-8 text-green-600" />,
    title: "Respon Cepat",
    desc: "Admin kami siap melayani pesanan dan pertanyaan Anda via WhatsApp dengan ramah dan cepat.",
  },
];

export default function TrustSection() {
  return (
    <section className="bg-white py-16 border-y border-slate-100">
      <div className="max-w-7xl mx-auto px-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
          {trustPoints.map((point, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 10 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: index * 0.1 }}
              className="flex items-start gap-4 p-4 rounded-2xl hover:bg-slate-50 transition-colors"
            >
              <div className="shrink-0 p-3 bg-green-600/10 rounded-xl">
                {point.icon}
              </div>
              <div>
                <h3 className="text-slate-900 font-bold text-lg mb-1">
                  {point.title}
                </h3>
                <p className="text-slate-500 text-sm leading-relaxed">
                  {point.desc}
                </p>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
