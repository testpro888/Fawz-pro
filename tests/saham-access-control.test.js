import { describe, it, expect, beforeEach, vi } from 'vitest';

/**
 * Tests for the access control logic in saham.html
 * Validates Requirements: 6.1, 6.2, 6.3, 6.4, 6.6, 6.7
 *
 * The actual IIFE in saham.html runs synchronously in the <head>.
 * This test validates the same logic extracted as a function.
 */

// Extracted access control logic matching the IIFE in saham.html
function checkSahamAccess(sessionStorageGet, localStorageGet) {
  const raw = sessionStorageGet('fawz_user') || localStorageGet('fawz_user_remember');

  // No session data found
  if (!raw) {
    return { action: 'redirect', target: 'login.html' };
  }

  // Attempt to parse JSON
  let user;
  try {
    user = JSON.parse(raw);
  } catch (e) {
    return { action: 'redirect', target: 'login.html' };
  }

  // Validate required fields (name, username, role) exist and are non-empty
  if (!user || typeof user !== 'object' || !user.name || !user.username || !user.role) {
    return { action: 'redirect', target: 'login.html' };
  }

  // Role-based access: "sales" → redirect to dashboard
  if (user.role === 'sales') {
    return { action: 'redirect', target: 'dashboard.html' };
  }

  // Only allow "admin" and "head_account" roles
  if (user.role !== 'admin' && user.role !== 'head_account') {
    return { action: 'redirect', target: 'dashboard.html' };
  }

  // Valid session
  return { action: 'allow', user, raw };
}

describe('Saham Access Control', () => {
  const noSession = () => null;
  const noLocal = () => null;

  describe('Requirement 6.4 - No valid session redirects to login', () => {
    it('redirects to login.html when no session or localStorage data exists', () => {
      const result = checkSahamAccess(noSession, noLocal);
      expect(result.action).toBe('redirect');
      expect(result.target).toBe('login.html');
    });

    it('redirects to login.html when sessionStorage is null and localStorage is null', () => {
      const result = checkSahamAccess(() => null, () => null);
      expect(result.action).toBe('redirect');
      expect(result.target).toBe('login.html');
    });

    it('redirects to login.html when sessionStorage is empty string', () => {
      const result = checkSahamAccess(() => '', noLocal);
      // Empty string is falsy, so falls through to localStorage
      // localStorage also returns null → redirect
      const result2 = checkSahamAccess(() => '', () => null);
      expect(result2.action).toBe('redirect');
      expect(result2.target).toBe('login.html');
    });
  });

  describe('Requirement 6.6 - Invalid JSON redirects to login', () => {
    it('redirects to login.html when stored value is not valid JSON', () => {
      const result = checkSahamAccess(() => 'not-json{{{', noLocal);
      expect(result.action).toBe('redirect');
      expect(result.target).toBe('login.html');
    });

    it('redirects to login.html when stored value is malformed JSON', () => {
      const result = checkSahamAccess(() => '{"name": "test"', noLocal);
      expect(result.action).toBe('redirect');
      expect(result.target).toBe('login.html');
    });

    it('redirects to login.html when JSON is valid but missing role field', () => {
      const data = JSON.stringify({ name: 'Test', username: 'test' });
      const result = checkSahamAccess(() => data, noLocal);
      expect(result.action).toBe('redirect');
      expect(result.target).toBe('login.html');
    });

    it('redirects to login.html when JSON is valid but missing name field', () => {
      const data = JSON.stringify({ username: 'test', role: 'admin' });
      const result = checkSahamAccess(() => data, noLocal);
      expect(result.action).toBe('redirect');
      expect(result.target).toBe('login.html');
    });

    it('redirects to login.html when JSON is valid but missing username field', () => {
      const data = JSON.stringify({ name: 'Test', role: 'admin' });
      const result = checkSahamAccess(() => data, noLocal);
      expect(result.action).toBe('redirect');
      expect(result.target).toBe('login.html');
    });

    it('redirects to login.html when parsed value is null', () => {
      const result = checkSahamAccess(() => 'null', noLocal);
      expect(result.action).toBe('redirect');
      expect(result.target).toBe('login.html');
    });

    it('redirects to login.html when parsed value is a string', () => {
      const result = checkSahamAccess(() => '"just a string"', noLocal);
      expect(result.action).toBe('redirect');
      expect(result.target).toBe('login.html');
    });

    it('redirects to login.html when parsed value is a number', () => {
      const result = checkSahamAccess(() => '42', noLocal);
      expect(result.action).toBe('redirect');
      expect(result.target).toBe('login.html');
    });
  });

  describe('Requirement 6.1 - Admin gets full access', () => {
    it('allows access for admin role', () => {
      const data = JSON.stringify({ name: 'Admin User', username: 'admin1', role: 'admin' });
      const result = checkSahamAccess(() => data, noLocal);
      expect(result.action).toBe('allow');
      expect(result.user.role).toBe('admin');
    });
  });

  describe('Requirement 6.2 - Head account gets full access', () => {
    it('allows access for head_account role', () => {
      const data = JSON.stringify({ name: 'Head Account', username: 'head1', role: 'head_account' });
      const result = checkSahamAccess(() => data, noLocal);
      expect(result.action).toBe('allow');
      expect(result.user.role).toBe('head_account');
    });
  });

  describe('Requirement 6.3 - Sales redirects to dashboard', () => {
    it('redirects sales role to dashboard.html', () => {
      const data = JSON.stringify({ name: 'Sales User', username: 'sales1', role: 'sales' });
      const result = checkSahamAccess(() => data, noLocal);
      expect(result.action).toBe('redirect');
      expect(result.target).toBe('dashboard.html');
    });
  });

  describe('Unknown roles redirect to dashboard', () => {
    it('redirects unknown role to dashboard.html', () => {
      const data = JSON.stringify({ name: 'Unknown', username: 'user1', role: 'manager' });
      const result = checkSahamAccess(() => data, noLocal);
      expect(result.action).toBe('redirect');
      expect(result.target).toBe('dashboard.html');
    });

    it('redirects empty role string to login.html (falsy check)', () => {
      const data = JSON.stringify({ name: 'User', username: 'user1', role: '' });
      const result = checkSahamAccess(() => data, noLocal);
      expect(result.action).toBe('redirect');
      expect(result.target).toBe('login.html');
    });
  });

  describe('localStorage fallback', () => {
    it('uses localStorage when sessionStorage is empty', () => {
      const data = JSON.stringify({ name: 'Admin', username: 'admin1', role: 'admin' });
      const result = checkSahamAccess(() => null, () => data);
      expect(result.action).toBe('allow');
      expect(result.user.role).toBe('admin');
    });

    it('prefers sessionStorage over localStorage', () => {
      const sessionData = JSON.stringify({ name: 'Admin', username: 'admin1', role: 'admin' });
      const localData = JSON.stringify({ name: 'Sales', username: 'sales1', role: 'sales' });
      const result = checkSahamAccess(() => sessionData, () => localData);
      expect(result.action).toBe('allow');
      expect(result.user.role).toBe('admin');
    });
  });
});
