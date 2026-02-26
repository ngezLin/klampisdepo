import { Link, useNavigate } from "react-router-dom";
import { logout } from "../services/authService";

export default function Unauthorized() {
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate("/login");
  };

  return (
    <div className="flex flex-col items-center justify-center h-screen bg-gray-100">
      <h1 className="text-3xl font-bold mb-4">Unauthorized</h1>
      <p className="mb-4">You do not have access to this page.</p>
      <div className="flex gap-4">
        <Link to="/login" className="bg-blue-600 text-white px-4 py-2 rounded">
          Go App Home
        </Link>
        <button
          onClick={handleLogout}
          className="bg-red-500 text-white px-4 py-2 rounded"
        >
          Logout
        </button>
      </div>
    </div>
  );
}
