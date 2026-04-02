import GenericTableView from '../common/GenericTableView';

/**
 * CRUD for `public.advisor_numbers`.
 * Expected columns: id, created_at, name, phone_number
 */
const AdvisorNumbersView = ({ showToast }: { showToast: (msg: string, type: 'success' | 'error') => void }) => (
  <GenericTableView
    title="Advisor Numbers"
    tableName="advisor_numbers"
    onToast={showToast}
    columns={[
      { key: 'name', label: 'Name', minWidth: 180, className: 'col-nowrap' },
      { key: 'phone_number', label: 'Phone', minWidth: 160, className: 'col-nowrap' },
      {
        key: 'created_at',
        label: 'Added',
        minWidth: 140,
        className: 'col-nowrap',
        formatter: (val: any) => (val ? new Date(val).toLocaleString() : '—'),
      },
    ]}
    fields={[
      { name: 'name', label: 'Display name', placeholder: 'e.g. Service advisor' },
      { name: 'phone_number', label: 'Phone number', placeholder: 'e.g. +971 50 000 0000' },
    ]}
  />
);

export default AdvisorNumbersView;
