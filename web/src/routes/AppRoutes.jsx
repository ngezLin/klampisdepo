import { Routes, Route, useLocation } from "react-router-dom";
import { AnimatePresence } from "framer-motion";
import PageTransition from "../components/common/PageTransition";
import Layout from "../components/Layout";
import ProtectedRoute from "./ProtectedRoute";

// Pages
import Dashboard from "../pages/Dashboard";
import Items from "../pages/Items";
import Transactions from "../pages/Transactions";
import History from "../pages/History";
import Attendance from "../pages/Attendance";
import InventoryHistory from "../pages/InventoryHistory";
import AuditLogs from "../pages/AuditLogs";
import CashSessions from "../pages/CashSessions";
import Login from "../pages/Login";
import LandingPage from "../pages/LandingPage";
import Unauthorized from "../pages/Unauthorized";
import NotFound from "../pages/NotFound";

export default function AppRoutes() {
  const location = useLocation();

  return (
    <AnimatePresence mode="wait">
      <Routes location={location} key={location.pathname}>
        {/* Public Routes */}
        <Route
          path="/"
          element={
            <PageTransition>
              <LandingPage />
            </PageTransition>
          }
        />
        <Route
          path="/login"
          element={
            <PageTransition>
              <Login />
            </PageTransition>
          }
        />
        <Route
          path="/unauthorized"
          element={
            <PageTransition>
              <Unauthorized />
            </PageTransition>
          }
        />

        {/* Private Routes */}
        <Route
          path="/dashboard"
          element={
            <ProtectedRoute roles={["owner"]}>
              <Layout>
                <PageTransition>
                  <Dashboard />
                </PageTransition>
              </Layout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/cash-sessions"
          element={
            <ProtectedRoute roles={["admin", "owner"]}>
              <Layout>
                <PageTransition>
                  <CashSessions />
                </PageTransition>
              </Layout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/items"
          element={
            <ProtectedRoute roles={["admin", "owner"]}>
              <Layout>
                <PageTransition>
                  <Items />
                </PageTransition>
              </Layout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/transactions"
          element={
            <ProtectedRoute roles={["cashier", "admin", "owner"]}>
              <Layout>
                <PageTransition>
                  <Transactions />
                </PageTransition>
              </Layout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/history"
          element={
            <ProtectedRoute roles={["cashier", "admin", "owner"]}>
              <Layout>
                <PageTransition>
                  <History />
                </PageTransition>
              </Layout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/inventory-history"
          element={
            <ProtectedRoute roles={["owner"]}>
              <Layout>
                <PageTransition>
                  <InventoryHistory />
                </PageTransition>
              </Layout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/attendance"
          element={
            <ProtectedRoute roles={["owner"]}>
              <Layout>
                <PageTransition>
                  <Attendance />
                </PageTransition>
              </Layout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/audit-logs"
          element={
            <ProtectedRoute roles={["owner"]}>
              <Layout>
                <PageTransition>
                  <AuditLogs />
                </PageTransition>
              </Layout>
            </ProtectedRoute>
          }
        />

        {/* 404 */}
        <Route
          path="*"
          element={
            <PageTransition>
              <NotFound />
            </PageTransition>
          }
        />
      </Routes>
    </AnimatePresence>
  );
}
