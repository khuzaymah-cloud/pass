import { Routes } from '@angular/router';
import { authGuard, loginGuard } from './core/guards/auth.guard';

export const routes: Routes = [
  {
    path: 'login',
    canActivate: [loginGuard],
    loadComponent: () => import('./features/login/login.component').then(m => m.LoginComponent),
  },
  {
    path: '',
    canActivate: [authGuard],
    loadComponent: () => import('./features/layout/layout.component').then(m => m.LayoutComponent),
    children: [
      { path: 'dashboard', loadComponent: () => import('./features/dashboard/dashboard.component').then(m => m.DashboardComponent) },
      { path: 'users', loadComponent: () => import('./features/users/users.component').then(m => m.UsersComponent) },
      { path: 'gyms', loadComponent: () => import('./features/gyms/gyms.component').then(m => m.GymsComponent) },
      { path: 'plans', loadComponent: () => import('./features/plans/plans.component').then(m => m.PlansComponent) },
      { path: 'subscriptions', loadComponent: () => import('./features/subscriptions/subscriptions.component').then(m => m.SubscriptionsComponent) },
      { path: 'checkins', loadComponent: () => import('./features/checkins/checkins.component').then(m => m.CheckinsComponent) },
      { path: 'payments', loadComponent: () => import('./features/payments/payments.component').then(m => m.PaymentsComponent) },
      { path: 'settlements', loadComponent: () => import('./features/settlements/settlements.component').then(m => m.SettlementsComponent) },
      { path: 'countries', loadComponent: () => import('./features/countries/countries.component').then(m => m.CountriesComponent) },
      { path: 'settings', loadComponent: () => import('./features/settings/settings.component').then(m => m.SettingsComponent) },
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
    ],
  },
  { path: '**', redirectTo: 'dashboard' },
];
