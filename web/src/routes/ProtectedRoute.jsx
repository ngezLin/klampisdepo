import { Navigate } from "react-router-dom";

export default function ProtectedRoute({ children, roles }) {
  const token = localStorage.getItem("token");

  if (!token) return <Navigate to="/login" replace />;

  if (roles) {
    try {
      const payload = JSON.parse(atob(token.split(".")[1]));
      if (!roles.includes(payload.role))
        return <Navigate to="/unauthorized" replace />;
    } catch {
      return <Navigate to="/login" replace />;
    }
  }

  return children;
}
