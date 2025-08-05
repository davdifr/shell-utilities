#!/bin/bash

# Function to share content via QR code
qr_share() {
    local share_file=false
    local share_text=""
    local port=8080
    local timeout=300  # 5 minutes default
    local cleanup_pid=""
    
    # Check if qrencode is available
    if ! command -v qrencode &> /dev/null; then
        echo "❌ qrencode not found. Install with: brew install qrencode"
        return 1
    fi
    
    # Handle parameters
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--file)
                share_file=true
                share_text="$2"
                shift 2
                ;;
            -p|--port)
                port="$2"
                shift 2
                ;;
            -t|--timeout)
                timeout="$2"
                shift 2
                ;;
            -h|--help)
                echo "Usage: qr_share [options] [text|url]"
                echo ""
                echo "Share text, URLs, or files via QR code"
                echo ""
                echo "Options:"
                echo "  -f, --file FILE    Share a file via temporary HTTP server"
                echo "  -p, --port PORT    Port for HTTP server (default: 8080)"
                echo "  -t, --timeout SEC  Auto-cleanup timeout in seconds (default: 300)"
                echo "  -h, --help         Show this help"
                echo ""
                echo "Examples:"
                echo "  qr_share 'Hello World'"
                echo "  qr_share 'https://github.com'"
                echo "  qr_share --file document.pdf"
                echo "  qr_share --file photo.jpg --port 3000"
                return 0
                ;;
            *)
                share_text="$1"
                shift
                ;;
        esac
    done
    
    # Function to cleanup background processes
    cleanup() {
        if [[ -n "$cleanup_pid" ]]; then
            kill "$cleanup_pid" 2>/dev/null
            echo ""
            echo "🧹 Server stopped"
        fi
    }
    
    # Setup cleanup on script exit (but don't trap EXIT to avoid terminal closure)
    trap cleanup INT TERM
    
    if [[ "$share_file" == true ]]; then
        # File sharing mode
        if [[ ! -f "$share_text" ]]; then
            echo "❌ File not found: $share_text"
            return 1
        fi
        
        # Check if port is available
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo "❌ Port $port is already in use"
            return 1
        fi
        
        local filename=$(basename "$share_text")
        local file_size=$(du -h "$share_text" | cut -f1)
        local file_dir=$(dirname "$(realpath "$share_text")")
        
        echo "📁 Sharing file: $filename ($file_size)"
        echo "🌐 Starting HTTP server on port $port..."
        
        # Get local IP address
        local local_ip=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "localhost")
        local share_url="http://$local_ip:$port/$filename"
        
        # Start Python HTTP server in background
        cd "$file_dir"
        if command -v python3 &> /dev/null; then
            python3 -m http.server $port >/dev/null 2>&1 &
        elif command -v python &> /dev/null; then
            python -m http.server $port >/dev/null 2>&1 &
        else
            echo "❌ Python not found. Cannot start HTTP server."
            return 1
        fi
        
        cleanup_pid=$!
        
        # Wait a moment for server to start
        sleep 2
        
        echo "📡 File available at: $share_url"
        echo ""
        echo "📱 Scan QR code to download:"
        echo ""
        
        # Generate QR code
        qrencode -t ANSIUTF8 "$share_url"
        
        echo ""
        echo "⏰ Server will auto-stop in $timeout seconds"
        echo "💡 Press Ctrl+C to stop manually"
        
        # Auto-cleanup after timeout
        sleep $timeout
        cleanup
        
    else
        # Text/URL sharing mode
        if [[ -z "$share_text" ]]; then
            echo "❌ Please provide text or URL to share"
            echo "Usage: qr_share 'your text here'"
            return 1
        fi
        
        echo "📝 Sharing: $share_text"
        echo ""
        echo "📱 Scan QR code:"
        echo ""
        
        # Generate QR code
        qrencode -t ANSIUTF8 "$share_text"
        
        echo ""
        echo "✅ QR code generated successfully!"
    fi
}

# Shorter alias
alias qr='qr_share'
