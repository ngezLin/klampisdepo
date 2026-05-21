import { motion } from "framer-motion";
import { MessageCircle, MapPin, LogIn } from "lucide-react";
import { Link } from "react-router-dom";

export default function Hero() {
  return (
    <div className="relative isolate pt-14 overflow-hidden bg-slate-50">
      {/* Background patterns */}
      <div className="absolute inset-0 z-0 opacity-10" 
           style={{ backgroundImage: 'radial-gradient(#16a34a 0.5px, transparent 0.5px)', backgroundSize: '24px 24px' }}>
      </div>

      <div className="py-24 sm:py-32 lg:pb-40 relative z-10">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-3xl">
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className="mb-8 flex"
            >
              <div className="flex items-center gap-2 rounded-full px-4 py-1.5 text-sm font-medium text-green-700 ring-1 ring-green-600/20 bg-green-600/5 backdrop-blur-sm">
                <MapPin className="w-4 h-4" />
                Jl. Klampis Harapan No. G-168, Sukolilo, Surabaya
              </div>
            </motion.div>

            <motion.h1
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 }}
              className="text-5xl font-black tracking-tight text-slate-900 sm:text-7xl leading-[1.1]"
            >
              Toko Bangunan Surabaya{" "}
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-green-600 to-emerald-600">
                Terpercaya & Hemat.
              </span>
            </motion.h1>

            <motion.p
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 }}
              className="mt-8 text-xl leading-8 text-slate-600 max-w-2xl"
            >
              Bangun rumah jadi lebih mudah. Klampis Depo siap kirim semen, pasir, cat, atau besi langsung ke lokasi Anda. Harga jujur, barang ready, pengiriman cepat di hari yang sama.
            </motion.p>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3 }}
              className="mt-12 flex flex-col sm:flex-row items-center gap-4"
            >
              <a
                href="https://wa.me/6281234567890"
                className="w-full sm:w-auto flex items-center justify-center gap-3 rounded-2xl bg-green-600 px-8 py-4 text-lg font-bold text-white shadow-xl shadow-green-900/20 hover:bg-green-700 transition-all group"
              >
                <MessageCircle className="w-6 h-6" />
                Pesan Lewat WhatsApp
              </a>
              <Link
                to="/login"
                className="w-full sm:w-auto flex items-center justify-center gap-2 rounded-2xl border border-slate-300 bg-white px-8 py-4 text-lg font-bold text-slate-700 shadow-sm hover:bg-slate-50 hover:text-slate-900 transition-all"
              >
                <LogIn className="w-5 h-5" />
                Login
              </Link>
            </motion.div>
          </div>

          {/* Removed redundant stats as they are merged below */}
        </div>
      </div>
    </div>
  );
}
