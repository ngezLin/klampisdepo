import { motion } from "framer-motion";
import { Link } from "react-router-dom";
import { ArrowRight, Sparkles, Shield, Zap } from "lucide-react";

export default function Hero() {
  return (
    <div className="relative isolate pt-14 overflow-hidden bg-[#0a0a0a]">
      {/* Animated Background Blobs */}
      <div className="absolute top-0 -left-4 w-96 h-96 bg-purple-600 rounded-full mix-blend-multiply filter blur-3xl opacity-10 animate-blob"></div>
      <div className="absolute top-0 -right-4 w-96 h-96 bg-blue-600 rounded-full mix-blend-multiply filter blur-3xl opacity-10 animate-blob animation-delay-2000"></div>
      <div className="absolute -bottom-8 left-20 w-96 h-96 bg-pink-600 rounded-full mix-blend-multiply filter blur-3xl opacity-10 animate-blob animation-delay-4000"></div>

      <div className="py-24 sm:py-32 lg:pb-40">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl text-center">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
              className="mb-8 flex justify-center"
            >
              <div className="relative rounded-full px-3 py-1 text-sm leading-6 text-gray-400 ring-1 ring-white/10 hover:ring-white/20 transition-all backdrop-blur-md">
                Announcing KlampisDepo Engine V2.{" "}
                <Link to="/login" className="font-semibold text-blue-400">
                  <span className="absolute inset-0" aria-hidden="true" />
                  Read more <span aria-hidden="true">&rarr;</span>
                </Link>
              </div>
            </motion.div>

            <motion.h1
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.8 }}
              className="text-4xl font-bold tracking-tight text-white sm:text-6xl"
            >
              Manage your inventory with{" "}
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-purple-400">
                unmatched precision.
              </span>
            </motion.h1>

            <motion.p
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.3, duration: 0.8 }}
              className="mt-6 text-lg leading-8 text-gray-300"
            >
              KlampisDepo provides the tools you need to track stock, manage
              transactions, and grow your business with a premium interface
              designed for speed.
            </motion.p>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.5, duration: 0.8 }}
              className="mt-10 flex items-center justify-center gap-x-6"
            >
              <Link
                to="/login"
                className="rounded-2xl bg-gradient-to-r from-blue-600 to-purple-600 px-8 py-4 text-sm font-bold text-white shadow-xl hover:shadow-blue-500/20 transition-all flex items-center gap-2 group"
              >
                Get Started
                <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
              </Link>
              <a
                href="#features"
                className="text-sm font-semibold leading-6 text-white flex items-center gap-2 hover:text-blue-400 transition-colors"
              >
                Learn more <span aria-hidden="true">→</span>
              </a>
            </motion.div>
          </div>

          {/* Featured Sections (Optional glass cards) */}
          <div className="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-none">
            <dl className="grid max-w-xl grid-cols-1 gap-x-8 gap-y-16 lg:max-w-none lg:grid-cols-3">
              <FeatureCard
                icon={Zap}
                title="Lightning Fast"
                description="Engineered for rapid data entry and instant stock updates."
              />
              <FeatureCard
                icon={Shield}
                title="Secure & Reliable"
                description="Enterprise-grade security for your business data and transactions."
              />
              <FeatureCard
                icon={Sparkles}
                title="Premium UX"
                description="A stunning interface that makes inventory management a delight."
              />
            </dl>
          </div>
        </div>
      </div>
    </div>
  );
}

function FeatureCard({ icon: Icon, title, description }) {
  return (
    <motion.div
      whileHover={{ y: -5 }}
      className="flex flex-col bg-white/5 backdrop-blur-lg border border-white/10 p-8 rounded-3xl shadow-xl hover:bg-white/[0.07] transition-all"
    >
      <dt className="flex items-center gap-x-3 text-base font-semibold leading-7 text-white">
        <div className="h-10 w-10 flex items-center justify-center rounded-xl bg-blue-600/20 text-blue-400">
          <Icon className="h-6 w-6" aria-hidden="true" />
        </div>
        {title}
      </dt>
      <dd className="mt-4 flex flex-auto flex-col text-base leading-7 text-gray-400">
        <p className="flex-auto">{description}</p>
      </dd>
    </motion.div>
  );
}
