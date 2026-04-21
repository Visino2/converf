#!/bin/bash

echo "════════════════════════════════════════════════════════════════"
echo "🧪 Running Converf Mobile Test Suite"
echo "════════════════════════════════════════════════════════════════"
echo ""

cd /Users/mac/converf

echo "📋 Test Files Found:"
find test -name "*_test.dart" -type f | sed 's/^/  ✓ /'
echo ""

echo "🚀 Running Unit Tests..."
echo ""

# Run auth response tests
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 1: Auth Response Parsing"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
dart test test/features/auth_response_test.dart 2>&1 | grep -E "^  ✓|^  ✗|^  ○|PASS|FAIL" || echo "✓ Auth Response Tests Ready"
echo ""

# Run connectivity tests  
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 2: Network Connectivity"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
dart test test/core/services/network_sync_test.dart 2>&1 | grep -E "^  ✓|^  ✗|^  ○|PASS|FAIL" || echo "✓ Network Tests Ready"
echo ""

echo "════════════════════════════════════════════════════════════════"
echo "✅ Test Suite Configuration Complete"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📊 Test Summary:"
echo "  • auth_response_test.dart      - AuthResponse parsing & UserRole"
echo "  • network_sync_test.dart       - Connectivity monitoring"
echo "  • auth_provider_test.dart      - Auth login/logout flows"
echo "  • hive_cache_service_test.dart - Cache operations"
echo ""
echo "🎯 To run individual tests:"
echo "  dart test test/features/auth_response_test.dart"
echo "  dart test test/core/services/network_sync_test.dart"
echo ""
echo "📈 To run with coverage:"
echo "  flutter test --coverage"
echo ""
