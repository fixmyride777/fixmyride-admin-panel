import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { X, Loader2 } from 'lucide-react';
import { supabase } from '../../lib/supabase';
import type { ToastType } from '../../types/index';

type Props = {
  isOpen: boolean;
  onClose: () => void;
  showToast: (message: string, type?: ToastType) => void;
};

const ChangePasswordModal = ({ isOpen, onClose, showToast }: Props) => {
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!isOpen) {
      setNewPassword('');
      setConfirmPassword('');
      setLoading(false);
    }
  }, [isOpen]);

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (newPassword.length < 6) {
      showToast('Password must be at least 6 characters.', 'error');
      return;
    }
    if (newPassword !== confirmPassword) {
      showToast('Passwords do not match.', 'error');
      return;
    }

    setLoading(true);
    const { error } = await supabase.auth.updateUser({ password: newPassword });
    setLoading(false);

    if (error) {
      showToast(error.message, 'error');
      return;
    }

    showToast('Password updated successfully.', 'success');
    onClose();
  };

  return (
    <div className="modal-overlay" role="presentation" onClick={onClose}>
      <motion.div
        className="modal-content"
        style={{ maxWidth: '420px', padding: 0 }}
        initial={{ scale: 0.95, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        exit={{ scale: 0.95, opacity: 0 }}
        onClick={(e) => e.stopPropagation()}
      >
        <div
          style={{
            position: 'sticky',
            top: 0,
            zIndex: 2,
            background: 'white',
            padding: '24px 32px 16px',
            borderBottom: '1px solid #f1f5f9',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: '12px',
          }}
        >
          <h2 style={{ margin: 0, fontSize: '1.25rem' }}>Change password</h2>
          <button type="button" className="modal-close" onClick={onClose} aria-label="Close" style={{ position: 'relative', top: 0, right: 0 }}>
            <X size={20} />
          </button>
        </div>

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px', padding: '24px 32px 32px' }}>
          <p style={{ margin: 0, fontSize: '13px', color: 'var(--text-muted)', lineHeight: 1.5 }}>
            Choose a new password for your account. You will stay signed in.
          </p>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
            <label style={{ fontSize: '14px', fontWeight: '600', color: 'var(--text-muted)' }}>New password</label>
            <input
              type="password"
              autoComplete="new-password"
              className="form-input"
              style={{ width: '100%', marginBottom: 0 }}
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              minLength={6}
              required
            />
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
            <label style={{ fontSize: '14px', fontWeight: '600', color: 'var(--text-muted)' }}>Confirm new password</label>
            <input
              type="password"
              autoComplete="new-password"
              className="form-input"
              style={{ width: '100%', marginBottom: 0 }}
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              minLength={6}
              required
            />
          </div>
          <div style={{ display: 'flex', gap: '12px', marginTop: '8px' }}>
            <button type="button" onClick={onClose} style={{ flex: 1, padding: '12px', borderRadius: '8px', border: '1px solid var(--border)', fontWeight: '600' }}>
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              style={{
                flex: 1,
                padding: '12px',
                borderRadius: '8px',
                background: 'var(--primary)',
                color: 'white',
                fontWeight: '700',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '8px',
              }}
            >
              {loading ? <Loader2 className="animate-spin" size={20} /> : 'Update password'}
            </button>
          </div>
        </form>
      </motion.div>
    </div>
  );
};

export default ChangePasswordModal;
