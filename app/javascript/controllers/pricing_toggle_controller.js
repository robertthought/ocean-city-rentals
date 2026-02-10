import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "toggle", "toggleKnob", "monthlyLabel", "annualLabel",
    "starterPrice", "starterPeriod",
    "proPrice", "proPeriod",
    "premiumPrice", "premiumPeriod",
    "comparisonToggle", "comparisonTable", "comparisonArrow"
  ]

  connect() {
    this.isAnnual = true
    this.prices = {
      starter: { annual: 249, monthly: 25 },
      pro: { annual: 499, monthly: 50 },
      premium: { annual: 899, monthly: 90 }
    }
  }

  toggle() {
    this.isAnnual = !this.isAnnual
    this.updatePrices()
    this.updateToggleUI()
  }

  updateToggleUI() {
    if (this.hasToggleKnobTarget) {
      if (this.isAnnual) {
        this.toggleKnobTarget.classList.add("translate-x-5")
        this.toggleKnobTarget.classList.remove("translate-x-0")
      } else {
        this.toggleKnobTarget.classList.remove("translate-x-5")
        this.toggleKnobTarget.classList.add("translate-x-0")
      }
    }

    if (this.hasToggleTarget) {
      this.toggleTarget.setAttribute("aria-checked", this.isAnnual.toString())
      if (this.isAnnual) {
        this.toggleTarget.classList.add("bg-blue-400")
        this.toggleTarget.classList.remove("bg-gray-300")
      } else {
        this.toggleTarget.classList.remove("bg-blue-400")
        this.toggleTarget.classList.add("bg-gray-300")
      }
    }

    if (this.hasAnnualLabelTarget && this.hasMonthlyLabelTarget) {
      if (this.isAnnual) {
        this.annualLabelTarget.classList.add("text-white")
        this.monthlyLabelTarget.classList.remove("text-white")
        this.monthlyLabelTarget.classList.add("text-blue-200")
      } else {
        this.monthlyLabelTarget.classList.add("text-white")
        this.annualLabelTarget.classList.remove("text-white")
        this.annualLabelTarget.classList.add("text-blue-200")
      }
    }
  }

  updatePrices() {
    const period = this.isAnnual ? "/year" : "/mo"

    if (this.hasStarterPriceTarget) {
      const price = this.isAnnual ? this.prices.starter.annual : this.prices.starter.monthly
      this.starterPriceTarget.textContent = `$${price}`
    }
    if (this.hasStarterPeriodTarget) {
      this.starterPeriodTarget.textContent = period
    }

    if (this.hasProPriceTarget) {
      const price = this.isAnnual ? this.prices.pro.annual : this.prices.pro.monthly
      this.proPriceTarget.textContent = `$${price}`
    }
    if (this.hasProPeriodTarget) {
      this.proPeriodTarget.textContent = period
    }

    if (this.hasPremiumPriceTarget) {
      const price = this.isAnnual ? this.prices.premium.annual : this.prices.premium.monthly
      this.premiumPriceTarget.textContent = `$${price}`
    }
    if (this.hasPremiumPeriodTarget) {
      this.premiumPeriodTarget.textContent = period
    }
  }

  toggleComparison() {
    if (this.hasComparisonTableTarget) {
      this.comparisonTableTarget.classList.toggle("hidden")
    }
    if (this.hasComparisonArrowTarget) {
      this.comparisonArrowTarget.classList.toggle("rotate-180")
    }
    if (this.hasComparisonToggleTarget) {
      const span = this.comparisonToggleTarget.querySelector("span")
      if (span) {
        const isHidden = this.comparisonTableTarget.classList.contains("hidden")
        span.textContent = isHidden ? "Show full feature comparison" : "Hide feature comparison"
      }
    }
  }
}
