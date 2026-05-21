import Hero from "../components/landing/Hero";
import Features from "../components/landing/Features";
import TrustSection from "../components/landing/TrustSection";
import OrderSteps from "../components/landing/OrderSteps";
import FAQSection from "../components/landing/FAQSection";
import MapSection from "../components/landing/MapSection";
import CTASection from "../components/landing/CTASection";
import Footer from "../components/landing/Footer";

export default function LandingPage() {
  return (
    <div className="min-h-screen flex flex-col bg-white scroll-smooth">
      <Hero />
      <TrustSection />
      <Features />
      <OrderSteps />
      <FAQSection />
      <MapSection />
      <CTASection />
      <Footer />
    </div>
  );
}
