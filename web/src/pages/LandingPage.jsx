import Hero from "../components/landing/Hero";
import Features from "../components/landing/Features";
import MapSection from "../components/landing/MapSection";
import Footer from "../components/landing/Footer";

export default function LandingPage() {
  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Hero />
      <Features />
      <MapSection />
      <Footer />
    </div>
  );
}
