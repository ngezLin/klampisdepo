import { Link } from "react-router-dom";

export default function Unauthorized() {
  return (
    <div className="flex flex-col items-center justify-center h-screen bg-gray-100">
      <h1 className="text-3xl font-bold mb-4">Unauthorized</h1>
      <p className="mb-4">You do not have access to this page.</p>
      <Link to="/login" className="bg-blue-600 text-white px-4 py-2 rounded">
        Go to Login
      </Link>
    </div>
  );
}
