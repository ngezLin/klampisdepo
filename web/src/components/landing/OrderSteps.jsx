import { motion } from "framer-motion";

const steps = [
  {
    number: "01",
    title: "Pilih Barang",
    desc: "Lihat katalog kami atau tanya langsung stok barang yang Anda butuhkan.",
  },
  {
    number: "02",
    title: "Chat WhatsApp",
    desc: "Hubungi admin kami untuk konfirmasi harga terbaru dan ongkos kirim.",
  },
  {
    number: "03",
    title: "Bayar",
    desc: "Lakukan pembayaran via Transfer Bank, QRIS, atau bayar di toko.",
  },
  {
    number: "04",
    title: "Kirim",
    desc: "Barang akan langsung dikirim ke alamat Anda di hari yang sama.",
  },
];

export default function OrderSteps() {
  return (
    <section className="bg-slate-50 py-24">
      <div className="max-w-7xl mx-auto px-6">
        <div className="text-center mb-16">
          <h2 className="text-3xl md:text-4xl font-bold text-slate-900 mb-4">Cara Pesan Gampang</h2>
          <p className="text-slate-500">Tidak perlu ribet, cukup 4 langkah barang sampai di rumah.</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 relative">
          {/* Connector Line for Desktop */}
          <div className="hidden lg:block absolute top-1/2 left-0 w-full h-0.5 bg-gradient-to-r from-transparent via-green-600/20 to-transparent -translate-y-12"></div>
          
          {steps.map((step, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, scale: 0.95 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              transition={{ delay: index * 0.1 }}
              className="relative z-10 flex flex-col items-center text-center group"
            >
              <div className="w-16 h-16 rounded-full bg-green-600 flex items-center justify-center text-white text-2xl font-black mb-6 shadow-[0_0_20px_rgba(22,163,74,0.3)] group-hover:scale-110 transition-transform">
                {step.number}
              </div>
              <h3 className="text-xl font-bold text-slate-900 mb-3">{step.title}</h3>
              <p className="text-slate-500 text-sm leading-relaxed max-w-[200px]">
                {step.desc}
              </p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
