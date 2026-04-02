import { useState, useEffect, useCallback } from 'react';
import { motion } from 'framer-motion';
import { Loader2 } from 'lucide-react';
import { supabase, supabaseUrl } from '../../lib/supabase';
import Header from '../common/Header';

const TABLE = 'chatbot_personality';

/** `text` first — live DB uses this column for personality body. */
const TEXT_KEYS = ['text', 'instructions', 'content', 'personality', 'prompt'] as const;

function pickText(row: Record<string, unknown> | null): string {
  if (!row) return '';
  for (const k of TEXT_KEYS) {
    const v = row[k];
    if (typeof v === 'string') return v;
  }
  return '';
}

function textColumnForRow(row: Record<string, unknown> | null): string {
  if (!row) return 'text';
  for (const k of TEXT_KEYS) {
    if (Object.prototype.hasOwnProperty.call(row, k)) return k;
  }
  return 'text';
}

const ChatbotPersonalityView = ({
  showToast,
}: {
  showToast: (msg: string, type: 'success' | 'error') => void;
}) => {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [text, setText] = useState('');
  const [rowId, setRowId] = useState<string | null>(null);
  const [textColumn, setTextColumn] = useState<string>('text');

  const load = useCallback(async () => {
    if (supabaseUrl.includes('placeholder')) {
      setLoading(false);
      return;
    }
    setLoading(true);
    try {
      const { data, error } = await (supabase as any)
        .from(TABLE)
        .select('*')
        .order('created_at', { ascending: true })
        .limit(1);

      if (error) throw error;
      const row = data?.[0] as Record<string, unknown> | undefined;
      if (row?.id) setRowId(String(row.id));
      else setRowId(null);
      const col = textColumnForRow(row ?? null);
      setTextColumn(col);
      setText(pickText(row ?? null));
    } catch (e: any) {
      console.warn(e);
      showToast(e?.message || 'Could not load personality.', 'error');
      setText('');
      setRowId(null);
    } finally {
      setLoading(false);
    }
  }, [showToast]);

  useEffect(() => {
    void load();
  }, [load]);

  const handleSave = async () => {
    if (supabaseUrl.includes('placeholder')) {
      showToast('Configure Supabase in .env to save.', 'error');
      return;
    }
    setSaving(true);
    try {
      const col = textColumn;
      const payload: Record<string, unknown> = { [col]: text };

      if (rowId) {
        const { error } = await (supabase as any).from(TABLE).update(payload).eq('id', rowId);
        if (error) throw error;
        showToast('Personality saved.', 'success');
      } else {
        const { data, error } = await (supabase as any)
          .from(TABLE)
          .insert([payload])
          .select('id')
          .single();
        if (error) throw error;
        if (data?.id) setRowId(String(data.id));
        showToast('Personality saved.', 'success');
      }
    } catch (e: any) {
      showToast(e?.message || 'Save failed.', 'error');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', padding: '100px' }}>
        <Loader2 className="animate-spin" size={40} color="var(--primary)" />
      </div>
    );
  }

  return (
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
      <Header title="Chatbot Personality" />
      <div className="card" style={{ padding: '24px' }}>
        <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginBottom: '16px' }}>
          Edit how the chatbot should sound and behave. {!rowId && 'Saving creates your first personality record.'}
        </p>
        <label
          style={{
            fontSize: '14px',
            fontWeight: '600',
            color: 'var(--text-muted)',
            display: 'block',
            marginBottom: '8px',
          }}
        >
          Personality &amp; instructions
        </label>
        <textarea
          className="form-input"
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder="Describe tone, rules, and how the assistant should help customers…"
          style={{
            width: '100%',
            minHeight: '280px',
            padding: '14px',
            resize: 'vertical',
            fontSize: '14px',
            lineHeight: 1.5,
            marginBottom: '20px',
          }}
        />
        <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
          <button
            type="button"
            className="btn-primary"
            disabled={saving}
            onClick={() => void handleSave()}
            style={{ padding: '12px 28px', fontWeight: 700 }}
          >
            {saving ? 'Saving…' : 'Save'}
          </button>
          <button
            type="button"
            onClick={() => void load()}
            style={{
              padding: '12px 20px',
              fontWeight: 600,
              borderRadius: '8px',
              border: '1px solid var(--border)',
              background: 'white',
            }}
          >
            Reload
          </button>
        </div>
      </div>
    </motion.div>
  );
};

export default ChatbotPersonalityView;
