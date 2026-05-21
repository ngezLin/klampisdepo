import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { ChevronDown } from "lucide-react";

const faqs = [
  {
    question: "Di mana lokasi Klampis Depo di Surabaya?",
    answer: "Toko fisik kami berlokasi di Jl. Klampis Harapan No. G-168, Sukolilo, Surabaya. Kami buka setiap hari untuk melayani kebutuhan bangunan Anda.",
  },
  {
    question: "Apakah Klampis Depo bisa kirim barang di hari yang sama?",
    answer: "Ya! Kami memiliki armada pengiriman sendiri yang siap mengirimkan semen, pasir, besi, dan material lainnya di hari yang sama (Same Day Delivery) untuk area Surabaya.",
  },
  {
    question: "Bagaimana cara melakukan pemesanan?",
    answer: "Sangat mudah! Anda cukup menghubungi admin kami melalui WhatsApp, konfirmasi stok dan harga, lalu tentukan metode pembayaran. Barang akan langsung dikirim ke lokasi Anda.",
  },
  {
    question: "Apakah bisa bayar di tempat (COD)?",
    answer: "Tentu. Kami mendukung pembayaran via Transfer Bank, QRIS, atau Cash (Tunai) saat barang sampai di lokasi Anda untuk keamanan dan kenyamanan transaksi.",
  },
  {
    question: "Material bangunan apa saja yang tersedia?",
    answer: "Kami menyediakan berbagai kebutuhan konstruksi mulai dari Semen (berbagai merk), Pasir Cor/Pasang, Besi Beton berbagai ukuran, Cat Tembok/Kayu, Genteng, Pipa PVC, hingga alat pertukangan lengkap.",
  },
];

export default function FAQSection() {
  const [openIndex, setOpenIndex] = useState(null);

  return (
    <section className="bg-slate-50 py-24 sm:py-32">
      <div className="max-w-3xl mx-auto px-6">
        <div className="text-center mb-16">
          <h2 className="text-3xl sm:text-4xl font-black text-slate-900 tracking-tight mb-4">
            Pertanyaan yang Sering Diajukan
          </h2>
          <p className="text-slate-500 text-lg">
            Informasi lengkap seputar layanan dan produk Klampis Depo.
          </p>
        </div>

        <div className="space-y-4">
          {faqs.map((faq, index) => (
            <div
              key={index}
              className="bg-white border border-slate-200 rounded-2xl overflow-hidden shadow-sm"
            >
              <button
                onClick={() => setOpenIndex(openIndex === index ? null : index)}
                className="w-full flex items-center justify-between p-6 text-left hover:bg-slate-50 transition-colors"
              >
                <span className="font-bold text-slate-900 text-lg">
                  {faq.question}
                </span>
                <ChevronDown
                  className={`w-5 h-5 text-slate-400 transition-transform duration-300 ${
                    openIndex === index ? "rotate-180" : ""
                  }`}
                />
              </button>
              <AnimatePresence>
                {openIndex === index && (
                  <motion.div
                    initial={{ height: 0, opacity: 0 }}
                    animate={{ height: "auto", opacity: 1 }}
                    exit={{ height: 0, opacity: 0 }}
                    transition={{ duration: 0.3, ease: "easeInOut" }}
                  >
                    <div className="p-6 pt-0 text-slate-600 leading-relaxed border-t border-slate-100 bg-slate-50/50">
                      {faq.answer}
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
