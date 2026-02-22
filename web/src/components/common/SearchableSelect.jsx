import React, { useState, useEffect, useRef } from "react";
import { ChevronDown, Check, Search, X } from "lucide-react";

/**
 * A reusable select component with search functionality.
 *
 * @param {Object} props
 * @param {Array} props.options - Array of objects with { id, name }
 * @param {string|number} props.value - Currently selected value (id)
 * @param {function} props.onChange - Callback when value changes
 * @param {function} props.onSearch - Callback for search input change
 * @param {string} props.selectedLabel - Label of selected item if not in options
 * @param {string} props.placeholder - Placeholder text
 * @param {string} props.label - Label text
 * @param {string} props.className - Additional classes
 * @param {boolean} props.disabled - Whether the select is disabled
 */
const SearchableSelect = ({
  options = [],
  value,
  onChange,
  onSearch,
  selectedLabel,
  placeholder = "Select...",
  label,
  className = "",
  disabled = false,
  onLoadMore,
  hasMore = false,
  loadingMore = false,
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");
  const [filteredOptions, setFilteredOptions] = useState(options);
  const wrapperRef = useRef(null);
  const inputRef = useRef(null);

  // Find selected option object or use selectedLabel
  const selectedOption = options.find((opt) => opt.id === value);
  const displayLabel = selectedOption
    ? selectedOption.name
    : selectedLabel || placeholder;

  // Determine which options to display: local filtered or raw options (if server-side search)
  // If onSearch is provided, we assume the parent handles filtering and passes updated options.
  // If no onSearch, we filter locally.
  const displayOptions = onSearch ? options : filteredOptions;

  // Local filtering effect
  useEffect(() => {
    if (!onSearch) {
      setFilteredOptions(
        options.filter((opt) =>
          opt.name.toLowerCase().includes(searchTerm.toLowerCase()),
        ),
      );
    }
  }, [searchTerm, options, onSearch]);

  // Server-side search trigger effect
  useEffect(() => {
    if (onSearch) {
      const timer = setTimeout(() => {
        onSearch(searchTerm);
      }, 300); // Debounce search
      return () => clearTimeout(timer);
    }
  }, [searchTerm, onSearch]);

  // Handle click outside to close dropdown
  useEffect(() => {
    function handleClickOutside(event) {
      if (wrapperRef.current && !wrapperRef.current.contains(event.target)) {
        setIsOpen(false);
        setSearchTerm(""); // Reset search on close
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, []);

  // Autofocus input when opened
  useEffect(() => {
    if (isOpen && inputRef.current) {
      inputRef.current.focus();
    }
  }, [isOpen]);

  const handleSelect = (option) => {
    onChange(option.id);
    setIsOpen(false);
    setSearchTerm("");
  };

  const handleClear = (e) => {
    e.stopPropagation();
    onChange("");
  };

  return (
    <div className={`relative ${className}`} ref={wrapperRef}>
      {label && (
        <label className="block text-sm font-medium text-gray-700 mb-1">
          {label}
        </label>
      )}

      {/* Trigger Button */}
      <div
        className={`
          w-full bg-white border rounded p-2 flex items-center justify-between cursor-pointer
          ${disabled ? "opacity-50 cursor-not-allowed bg-gray-100" : "hover:border-blue-500"}
          ${isOpen ? "border-blue-500 ring-1 ring-blue-500" : "border-gray-300"}
        `}
        onClick={() => !disabled && setIsOpen(!isOpen)}
      >
        <span
          className={`block truncate ${!selectedOption && !selectedLabel ? "text-gray-400" : "text-gray-900"}`}
        >
          {displayLabel}
        </span>

        <div className="flex items-center gap-1">
          {value && !disabled && (
            <div
              onClick={handleClear}
              className="p-1 hover:bg-gray-200 rounded-full text-gray-500 transition-colors"
            >
              <X size={14} />
            </div>
          )}
          <ChevronDown size={16} className="text-gray-500" />
        </div>
      </div>

      {/* Dropdown Menu */}
      {isOpen && (
        <div className="absolute z-50 mt-1 w-full bg-white shadow-lg max-h-60 rounded-md py-1 text-base ring-1 ring-black ring-opacity-5 overflow-hidden focus:outline-none sm:text-sm">
          {/* Search Input */}
          <div className="p-2 border-b sticky top-0 bg-white z-10">
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <Search size={14} className="text-gray-400" />
              </div>
              <input
                ref={inputRef}
                type="text"
                className="block w-full pl-9 pr-3 py-2 border border-gray-300 rounded-md leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:border-blue-500 focus:ring-1 focus:ring-blue-500 sm:text-sm"
                placeholder="Search..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                onClick={(e) => e.stopPropagation()}
              />
            </div>
          </div>

          {/* Options List */}
          <div className="max-h-48 overflow-auto">
            {displayOptions.length === 0 ? (
              <div className="cursor-default select-none relative py-2 px-4 text-gray-700 text-center italic">
                No items found.
              </div>
            ) : (
              <>
                {displayOptions.map((option) => (
                  <div
                    key={option.id}
                    className={`cursor-pointer select-none relative py-2 pl-3 pr-9 hover:bg-blue-50 ${
                      value === option.id
                        ? "bg-blue-100 text-blue-900"
                        : "text-gray-900"
                    }`}
                    onClick={() => handleSelect(option)}
                  >
                    <span
                      className={`block truncate ${
                        value === option.id ? "font-semibold" : "font-normal"
                      }`}
                    >
                      {option.name}
                    </span>
                    {value === option.id && (
                      <span className="absolute inset-y-0 right-0 flex items-center pr-4 text-blue-600">
                        <Check size={16} />
                      </span>
                    )}
                  </div>
                ))}
                {onLoadMore && hasMore && (
                  <div
                    className="py-2 px-3 text-center text-blue-600 hover:bg-blue-50 cursor-pointer text-sm font-medium border-t bg-gray-50"
                    onClick={(e) => {
                      e.stopPropagation();
                      if (!loadingMore) onLoadMore();
                    }}
                  >
                    {loadingMore ? "Loading..." : "Load More"}
                  </div>
                )}
              </>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default SearchableSelect;
