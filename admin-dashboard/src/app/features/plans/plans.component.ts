import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminService } from '../../core/services/admin.service';
import { DataTableComponent, TableColumn } from '../../shared/components/data-table/data-table.component';
import { LoadingSpinnerComponent } from '../../shared/components/loading-spinner/loading-spinner.component';
import { Plan } from '../../core/models';

@Component({
  selector: 'app-plans',
  standalone: true,
  imports: [CommonModule, FormsModule, DataTableComponent, LoadingSpinnerComponent],
  template: `
    <div class="page">
      <div class="page-header">
        <h1>Plans</h1>
        <button class="btn-add" (click)="openCreate()">+ Add Plan</button>
      </div>
      @if (loading()) { <app-loading-spinner /> }
      @else { <app-data-table [columns]="columns" [data]="tableData()" (action)="onAction($event)" /> }
    </div>

    @if (showModal()) {
      <div class="modal-backdrop" (click)="closeModal()">
        <div class="modal" (click)="$event.stopPropagation()">
          <div class="modal-header">
            <h2>{{ modalMode() === 'create' ? 'Create Plan' : modalMode() === 'edit' ? 'Edit Plan' : 'Plan Details' }}</h2>
            <button class="close-btn" (click)="closeModal()">✕</button>
          </div>
          <div class="modal-body">
            @if (modalMode() === 'view' && selectedPlan()) {
              <div class="detail-grid">
                <div class="detail-item"><span class="label">ID</span><span class="value id-val">{{ selectedPlan()!.id }}</span></div>
                <div class="detail-item"><span class="label">Name (EN)</span><span class="value">{{ selectedPlan()!.name_en }}</span></div>
                <div class="detail-item"><span class="label">Name (AR)</span><span class="value">{{ selectedPlan()!.name_ar }}</span></div>
                <div class="detail-item"><span class="label">Tier</span><span class="value badge" [style.color]="tierColor(selectedPlan()!.tier)">{{ selectedPlan()!.tier }}</span></div>
                <div class="detail-item"><span class="label">Price (JD)</span><span class="value">{{ selectedPlan()!.price_local }}</span></div>
                <div class="detail-item"><span class="label">Daily Rate</span><span class="value">{{ selectedPlan()!.daily_rate }}</span></div>
                <div class="detail-item"><span class="label">Max Visits</span><span class="value">{{ selectedPlan()!.max_visits }}</span></div>
                <div class="detail-item"><span class="label">Validity Days</span><span class="value">{{ selectedPlan()!.validity_days }}</span></div>
                <div class="detail-item"><span class="label">Gym Access</span><span class="value badge" [style.color]="tierColor(selectedPlan()!.gym_tier_access)">Up to {{ selectedPlan()!.gym_tier_access }}</span></div>
                <div class="detail-item"><span class="label">Active</span><span class="value">{{ selectedPlan()!.is_active ? '✅ Yes' : '❌ No' }}</span></div>
                <div class="detail-item full"><span class="label">Features (EN)</span><span class="value">{{ selectedPlan()!.features_en?.join(', ') || '—' }}</span></div>
                <div class="detail-item full"><span class="label">Features (AR)</span><span class="value">{{ selectedPlan()!.features_ar?.join(', ') || '—' }}</span></div>
              </div>
              <div class="modal-actions">
                <button class="btn-edit" (click)="switchToEdit()">✏️ Edit</button>
              </div>
            }
            @if (modalMode() === 'edit' || modalMode() === 'create') {
              <div class="form-grid">
                <div class="form-group"><label>Name (EN) *</label><input [(ngModel)]="form.name_en" placeholder="Silver"></div>
                <div class="form-group"><label>Name (AR) *</label><input [(ngModel)]="form.name_ar" placeholder="فضي"></div>
                <div class="form-group"><label>Tier *</label>
                  <select [(ngModel)]="form.tier"><option value="silver">Silver</option><option value="gold">Gold</option><option value="platinum">Platinum</option><option value="diamond">Diamond</option></select>
                </div>
                <div class="form-group"><label>Gym Access Up To *</label>
                  <select [(ngModel)]="form.gym_tier_access"><option value="standard">Standard</option><option value="gold">Gold</option><option value="platinum">Platinum</option><option value="diamond">Diamond</option></select>
                </div>
                <div class="form-group"><label>Price (JD) *</label><input type="number" [(ngModel)]="form.price_local" step="0.001"></div>
                <div class="form-group"><label>Max Visits</label><input type="number" [(ngModel)]="form.max_visits"></div>
                <div class="form-group"><label>Validity Days</label><input type="number" [(ngModel)]="form.validity_days"></div>
                <div class="form-group"><label>Sort Order</label><input type="number" [(ngModel)]="form.sort_order"></div>
                <div class="form-group full"><label>Features EN (comma separated)</label><input [(ngModel)]="form.features_en_str" placeholder="Access to standard gyms, 30 visits per month"></div>
                <div class="form-group full"><label>Features AR (comma separated)</label><input [(ngModel)]="form.features_ar_str" placeholder="دخول نوادي عادية, 30 زيارة شهرياً"></div>
                <div class="form-group"><label>Active</label>
                  <select [(ngModel)]="form.is_active"><option [ngValue]="true">Active</option><option [ngValue]="false">Inactive</option></select>
                </div>
              </div>
              @if (formError()) { <div class="form-error">{{ formError() }}</div> }
              <div class="modal-actions">
                <button class="btn-cancel" (click)="closeModal()">Cancel</button>
                <button class="btn-save" (click)="save()" [disabled]="saving()">
                  {{ saving() ? 'Saving...' : modalMode() === 'create' ? 'Create Plan' : 'Save Changes' }}
                </button>
              </div>
            }
          </div>
        </div>
      </div>
    }
  `,
  styles: [`
    .page { padding: 32px; }
    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
    .page-header h1 { color: var(--text-primary); font-size: 24px; margin: 0; }
    .btn-add { background: var(--accent); color: var(--bg-primary); border: none; border-radius: 8px; padding: 8px 16px; font-weight: 700; cursor: pointer; font-size: 14px; }
    .modal-backdrop { position: fixed; inset: 0; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; z-index: 1000; }
    .modal { background: var(--bg-card); border: 1px solid var(--border); border-radius: 16px; width: 100%; max-width: 660px; max-height: 90vh; overflow-y: auto; }
    .modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; border-bottom: 1px solid var(--border); }
    .modal-header h2 { color: var(--text-primary); font-size: 20px; margin: 0; }
    .close-btn { background: none; border: none; color: var(--text-muted); font-size: 20px; cursor: pointer; }
    .modal-body { padding: 24px; }
    .detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px; }
    .detail-item { display: flex; flex-direction: column; gap: 4px; }
    .detail-item.full { grid-column: 1 / -1; }
    .label { color: var(--text-muted); font-size: 12px; font-weight: 600; text-transform: uppercase; }
    .value { color: var(--text-primary); font-size: 14px; } .id-val { font-size: 11px; color: #666; word-break: break-all; }
    .badge { font-weight: 700; }
    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px; }
    .form-group { display: flex; flex-direction: column; gap: 6px; }
    .form-group.full { grid-column: 1 / -1; }
    .form-group label { color: var(--text-muted); font-size: 12px; font-weight: 600; }
    .form-group input, .form-group select { background: var(--bg-input); border: 1px solid var(--border-light); border-radius: 8px; padding: 10px 12px; color: var(--text-primary); font-size: 14px; outline: none; }
    .form-group input:focus, .form-group select:focus { border-color: var(--accent); }
    .form-error { background: var(--error-bg); border: 1px solid var(--error-border); color: var(--error); padding: 8px 12px; border-radius: 8px; font-size: 13px; margin-bottom: 16px; }
    .modal-actions { display: flex; gap: 8px; justify-content: flex-end; }
    .btn-cancel { background: var(--border); border: 1px solid var(--border-light); border-radius: 8px; padding: 10px 20px; color: var(--text-muted); cursor: pointer; font-size: 14px; }
    .btn-save { background: var(--accent); color: var(--bg-primary); border: none; border-radius: 8px; padding: 10px 20px; font-weight: 700; cursor: pointer; font-size: 14px; }
    .btn-save:disabled { opacity: 0.5; }
    .btn-edit { background: var(--border); border: 1px solid var(--info); border-radius: 8px; padding: 8px 16px; color: var(--info); cursor: pointer; font-size: 13px; }
  `]
})
export class PlansComponent implements OnInit {
  loading = signal(true);
  plans = signal<Plan[]>([]);
  tableData = signal<Record<string, unknown>[]>([]);
  showModal = signal(false);
  modalMode = signal<'view' | 'edit' | 'create'>('view');
  selectedPlan = signal<Plan | null>(null);
  saving = signal(false);
  formError = signal('');
  form = { name_en: '', name_ar: '', tier: 'silver', price_local: 25, max_visits: 30, validity_days: 30, gym_tier_access: 'standard', features_en_str: '', features_ar_str: '', is_active: true, sort_order: 0 };

  columns: TableColumn[] = [
    { key: 'name_en', label: 'Name' },
    { key: 'tier', label: 'Tier', type: 'badge', badgeColors: { silver: 'var(--text-muted)', gold: 'var(--warning)', platinum: '#AF52DE', diamond: 'var(--info)' } },
    { key: 'price_local', label: 'Price (JD)' },
    { key: 'daily_rate', label: 'Daily Rate' },
    { key: 'max_visits', label: 'Max Visits' },
    { key: 'gym_tier_access', label: 'Access Up To', type: 'badge', badgeColors: { standard: 'var(--text-muted)', gold: 'var(--warning)', platinum: '#AF52DE', diamond: 'var(--info)' } },
    { key: 'is_active', label: 'Active', type: 'boolean' },
    { key: 'id', label: 'Actions', type: 'actions' },
  ];

  private adminService = inject(AdminService);
  ngOnInit(): void { this.load(); }

  load(): void {
    this.loading.set(true);
    this.adminService.getPlans().subscribe({
      next: (data: Plan[]) => { this.plans.set(data); this.tableData.set(data as unknown as Record<string, unknown>[]); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  onAction(event: { action: string; row: Record<string, unknown> }): void {
    const id = event.row['id'] as string;
    const plan = this.plans().find(p => p.id === id);
    if (!plan) return;
    if (event.action === 'view') { this.selectedPlan.set(plan); this.modalMode.set('view'); this.showModal.set(true); }
    if (event.action === 'edit') { this.openEdit(plan); }
  }

  openCreate(): void {
    this.form = { name_en: '', name_ar: '', tier: 'silver', price_local: 25, max_visits: 30, validity_days: 30, gym_tier_access: 'standard', features_en_str: '', features_ar_str: '', is_active: true, sort_order: 0 };
    this.formError.set(''); this.modalMode.set('create'); this.showModal.set(true);
  }

  openEdit(plan: Plan): void {
    this.selectedPlan.set(plan);
    this.form = { name_en: plan.name_en, name_ar: plan.name_ar, tier: plan.tier, price_local: parseFloat(plan.price_local), max_visits: plan.max_visits, validity_days: plan.validity_days, gym_tier_access: plan.gym_tier_access, features_en_str: plan.features_en?.join(', ') || '', features_ar_str: plan.features_ar?.join(', ') || '', is_active: plan.is_active, sort_order: plan.sort_order };
    this.formError.set(''); this.modalMode.set('edit'); this.showModal.set(true);
  }

  switchToEdit(): void { const p = this.selectedPlan(); if (p) this.openEdit(p); }

  save(): void {
    if (!this.form.name_en || !this.form.name_ar) { this.formError.set('Names are required'); return; }
    this.saving.set(true);
    const body: Record<string, unknown> = {
      name_en: this.form.name_en, name_ar: this.form.name_ar, tier: this.form.tier,
      price_local: String(this.form.price_local), max_visits: this.form.max_visits,
      validity_days: this.form.validity_days, gym_tier_access: this.form.gym_tier_access,
      features_en: this.form.features_en_str ? this.form.features_en_str.split(',').map((s: string) => s.trim()) : [],
      features_ar: this.form.features_ar_str ? this.form.features_ar_str.split(',').map((s: string) => s.trim()) : [],
      is_active: this.form.is_active, sort_order: this.form.sort_order,
    };
    const obs = this.modalMode() === 'create'
      ? this.adminService.createPlan(body)
      : this.adminService.updatePlan(this.selectedPlan()!.id, body);
    obs.subscribe({
      next: () => { this.closeModal(); this.load(); },
      error: (e: { error?: { detail?: string } }) => { this.formError.set(e.error?.detail || 'Failed'); this.saving.set(false); },
    });
  }

  closeModal(): void { this.showModal.set(false); this.selectedPlan.set(null); this.saving.set(false); }
  tierColor(t: string): string { return ({ silver: 'var(--text-muted)', gold: 'var(--warning)', platinum: '#AF52DE', diamond: 'var(--info)' } as Record<string, string>)[t] || 'var(--text-muted)'; }
}
