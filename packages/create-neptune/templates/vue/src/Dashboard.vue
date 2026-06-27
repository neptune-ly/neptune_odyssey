<script setup lang="ts">
import type { ModeOption } from "@neptune.fintech/vue-ui";

defineProps<{ mode: ModeOption }>();
defineEmits<{ (e: "toggle-mode"): void }>();

function sendMoney() {
  window.alert("Wire this button to your transfer flow.");
}
</script>

<template>
  <div class="app">
    <header class="app__bar">
      <span class="app__brand">{{PROJECT_TITLE}}</span>
      <button class="app__mode" type="button" @click="$emit('toggle-mode')">
        {{ mode === "dark" ? "☀ Light" : "☾ Dark" }}
      </button>
    </header>

    <main class="app__body">
      <npt-balance-card
        hero
        label="Available balance"
        amount="12,480.50"
        currency="LYD"
        account="•••• 4821"
      ></npt-balance-card>

      <div class="stat-row">
        <npt-stat-card label="Income" value="9,120" unit="LYD" delta="+8.2%"></npt-stat-card>
        <npt-stat-card label="Spending" value="3,540" unit="LYD" delta="-2.1%"></npt-stat-card>
      </div>

      <npt-quick-actions>
        <npt-quick-action label="Send"><npt-icon slot="icon" name="transfer"></npt-icon></npt-quick-action>
        <npt-quick-action label="Request"><npt-icon slot="icon" name="wallet"></npt-icon></npt-quick-action>
        <npt-quick-action label="Pay"><npt-icon slot="icon" name="card"></npt-icon></npt-quick-action>
        <npt-quick-action label="Top up"><npt-icon slot="icon" name="card-add"></npt-icon></npt-quick-action>
      </npt-quick-actions>

      <p class="section-title">Recent activity</p>
      <npt-card variant="outlined" class="txns">
        <npt-transaction-row title="Salary" subtitle="Today · Transfer" amount="+3,200.00" currency="LYD" credit></npt-transaction-row>
        <npt-transaction-row title="Grocery Market" subtitle="Yesterday · Card" amount="-86.40" currency="LYD"></npt-transaction-row>
        <npt-transaction-row title="Electricity" subtitle="Mon · Bill" amount="-120.00" currency="LYD"></npt-transaction-row>
        <npt-transaction-row title="Refund" subtitle="Sun · OnePay" amount="+45.00" currency="LYD" credit></npt-transaction-row>
      </npt-card>

      <npt-button variant="filled" @click="sendMoney">Send money</npt-button>
    </main>

    <nav class="app__nav">
      <npt-nav-bar>
        <npt-nav-item label="Home" active><npt-icon name="home"></npt-icon></npt-nav-item>
        <npt-nav-item label="Cards"><npt-icon name="card"></npt-icon></npt-nav-item>
        <npt-nav-item label="Pay"><npt-icon name="transfer"></npt-icon></npt-nav-item>
        <npt-nav-item label="More"><npt-icon name="settings"></npt-icon></npt-nav-item>
      </npt-nav-bar>
    </nav>
  </div>
</template>
