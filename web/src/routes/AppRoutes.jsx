import { Routes, Route } from "react-router-dom";
import Dashboard from "../pages/Dashboard";
import Items from "../pages/Items";
import Transactions from "../pages/Transactions";
import History from "../pages/History";
import InventoryHistory from "../pages/InventoryHistory";
import Attendance from "../pages/Attendance";
import Login from "../pages/Login";
import Unauthorized from "../pages/Unauthorized";
import LandingPage from "../pages/LandingPage";
import ProtectedRoute from "./ProtectedRoute";
import Layout from "../components/Layout";
import AuditLogs from "../pages/AuditLogs";
import CashSessions from "../pages/CashSessions";
import NotFound from "../pages/NotFound";

export default function AppRoutes() {
  return (
    <Routes>
      {/* Public */}
      <Route path="/" element={<LandingPage />} />
      <Route path="/login" element={<Login />} />
      <Route path="/unauthorized" element={<Unauthorized />} />

      {/* Protected with Layout */}
      <Route
        path="/dashboard"
        element={
          <ProtectedRoute roles={["owner"]}>
            <Layout>
              <Dashboard />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/items"
        element={
          <ProtectedRoute roles={["admin", "owner"]}>
            <Layout>
              <Items />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/transactions"
        element={
          <ProtectedRoute roles={["cashier", "admin", "owner"]}>
            <Layout>
              <Transactions />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/history"
        element={
          <ProtectedRoute roles={["cashier", "admin", "owner"]}>
            <Layout>
              <History />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/inventory-history"
        element={
          <ProtectedRoute roles={["owner"]}>
            <Layout>
              <InventoryHistory />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/attendance"
        element={
          <ProtectedRoute roles={["owner"]}>
            <Layout>
              <Attendance />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/audit-logs"
        element={
          <ProtectedRoute roles={["owner"]}>
            <Layout>
              <AuditLogs />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/cash-sessions"
        element={
          <ProtectedRoute roles={["admin", "owner"]}>
            <Layout>
              <CashSessions />
            </Layout>
          </ProtectedRoute>
        }
      />

      {/* 404 Catch-all */}
      <Route path="*" element={<NotFound />} />
    </Routes>
  );
}
