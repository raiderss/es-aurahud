const app = new Vue({
  el: '#app',
  data: {
    selectedGear: null,
    connected: false,
    width: window.innerWidth,
    height: window.innerHeight,
    player: {
      job: 'POLICE OFFIER',
      money: 10.000,
      ping: 50,
      online: 12
    },
    gear: {
      N: { gear: "N", color: '#D387F7' },
      1: { gear: 1, color: '#D387F7' },
      2: { gear: 2, color: '#D387F7' },
      3: { gear: 3, color: '#D387F7' },
      4: { gear: 4, color: '#D387F7' },
      5: { gear: 5, color: '#D387F7' },
      6: { gear: 6, color: '#D387F7' }
    },
    speedometer: {
      lights: { color: "#585858" },
      door: { color: "#585858" },
      seatbelt: { color: "#585858" },
      speed: { color: "#585858" },
      signal: {
        left: { color: "#585858" },
        right: { color: "#585858" }
      },
      hz: 50,
      noss: { percentage: 0, color: '#F64852' },
      fuel: { percentage: 50, color: '#F7D187' },
      rpm: { percentage: 0, color: '#E8B8FF' }
    },
    getType: 'civilian',
    getStats: {
      civilian: {
        hunger: { left: '3.4375rem', top: '60.85rem' },
        water: { left: '16.2rem', top: '60.85rem' },
        stress: { left: '10.2rem', top: '60rem' },
        health: { left: '16.2rem', top: '63rem' },
        armor: { left: '3.4375rem', top: '63rem' },
        oxygen: { left: '10.2rem', top: '63rem' }
      },
      car: {
        hunger: { left: '3.8rem', top: '49.5rem' },
        water: { left: '16.3rem', top: '49.5rem' },
        stress: { left: '10.8rem', top: '48.7rem' },
        health: { left: '16.3rem', top: '63.2rem' },
        armor: { left: '3.8rem', top: '63.2rem' },
        oxygen: { left: '10.8rem', top: '63.23rem' }
      }
    },
    hud: {
      health: { percentage: 100, color: '#FF0550' },
      armor: { percentage: 100, color: '#00A3FF' },
      hunger: { percentage: 100, color: '#ADFE00' },
      stress: { percentage: 0, color: '#AE6FE0' },
      water: { percentage: 100, color: "#00FFF0F7" },
      oxygen: { percentage: 100, color: '#FFB800' }
    }
  },

  methods: {
    selectGear(gearNumber) {
      this.selectedGear = gearNumber;
    
      this.$nextTick(() => {
        if (!this.$refs.gear) return;
        const gearListElement = this.$refs.gear;
        const gearNumberStr = String(gearNumber);
        const index = this.sortedGear.findIndex(data => String(data.gear) === gearNumberStr);
    
        if (index !== -1 && gearListElement.querySelector) {
          const listElements = gearListElement.querySelectorAll('.list');
          if (listElements.length > 0) {
            const singleGearWidth = listElements[0].offsetWidth;
            const left = (gearNumber === 2) ? 20 : 9;
            const scrollTo = index * (singleGearWidth + left);
            gearListElement.scrollLeft = scrollTo;
          }
        }
      });
    },

    mapSet(value) {
      this.$nextTick(() => {
        const refs = { speed: this.$refs.speed, gear: this.$refs.gear };
        if (value === 'car') {
          if (refs.speed && refs.gear && typeof anime === 'function') {
            anime({
              targets: refs.speed,
              translateY: [200, 0],
              opacity: [0.5, 1],
              duration: 750,
              easing: 'easeInOutQuad'
            });
            anime({
              targets: refs.gear,
              translateY: [200, 0],
              opacity: [0.5, 1],
              duration: 750,
              easing: 'easeInOutQuad'
            });
          }
        } else {
          if (refs.speed && refs.gear && typeof anime === 'function') {
            anime({
              targets: refs.speed,
              translateY: [0, 250],
              opacity: [1, 0],
              duration: 1000,
              easing: 'easeInOutQuad'
            });
            anime({
              targets: refs.gear,
              translateY: [0, 250],
              opacity: [1, 0],
              duration: 1000,
              easing: 'easeInOutQuad'
            });
          }
        }
      });
    },

    calculateWidth(type, percentage) {
      const multipliers = {
        hunger: 0.75,
        stress: 1.5,
        water: 1.17,
        armor: 1.53,
        oxygen: 1.5,
        health: 1.53
      };
      return (percentage * (multipliers[type] || 1)) + '%';
    }
  },

  created() {
    const self = this;
    window.addEventListener('message', function(event) {
      const item = event.data;
      const actions = {
        "CAR": () => {
          self.getType = "car";
          self.speedometer.hz = item.speed;
          self.speedometer.rpm.percentage = item.rpm;
          self.speedometer.fuel.percentage = item.fuel;
          self.selectGear(item.gear); 
          self.speedometer.seatbelt.color = item.seatbelt ? "#D387F7" : "#585858";
          self.speedometer.lights.color = item.state ? "#3C9172" : "#585858";
          const { left, right } = self.speedometer.signal;
          const colors = {
            2: ['#83F666', '#585858'],
            1: ['#585858', '#83F666'],
            3: ['#83F666', '#83F666']
          };
          const [leftColor, rightColor] = colors[item.signal] || ['#585858', '#585858'];
          left.color = leftColor;
          right.color = rightColor;
        },
        "NOT": () => self.getType = "civilian",
        "HEALTH": () => self.hud.health.percentage = item.health,
        "ARMOR": () => self.hud.armor.percentage = item.armor,
        "OXYGEN": () => self.hud.oxygen.percentage = item.oxygen,
        "STATUS": () => {
          self.hud.water.percentage = item.thirst;
          self.hud.hunger.percentage = item.hunger;
          self.connected = true;
        },
        "UPDATE_NOSS": () => self.speedometer.noss.percentage = item.noss,
        "STRESS": () => self.hud.stress.percentage = item.stress,
        "SPEEDLMT": () => self.speedometer.speed.color = item.variable ? "#FF0550" : "#585858",
        "DATA": () => {
          self.player.job = item.job;
          self.player.money = item.cash.toLocaleString('en-US', {
            style: 'currency',
            currency: 'USD'
          });
          self.player.online = item.count;
          self.player.ping = item.ping;
        }
      };
  
      const actionFunc = actions[item.action];
      if (actionFunc) actionFunc();
    });
  },

  mounted() {
    if (this.width >= 2560 && this.height >= 1440) {
      this.getStats.car.hunger = { left:'3.4375rem', top:'49.05rem' };
      this.getStats.car.water = { left:'16.3rem', top:'49.05rem' };
      this.getStats.car.stress = { left:'10.8rem', top:'48.2rem' };
      this.getStats.car.oxygen = { left:'10.8rem', top:'63rem' };
    }
  },

  computed: {
    sortedGear() {
      return Object.values(this.gear).sort((a, b) => {
        if (a.gear === "N") return -1;
        if (b.gear === "N") return 1;
        return a.gear - b.gear;
      });
    },
    gearColor() {
      return gearNumber => {
        if (this.selectedGear === gearNumber) {
          return this.gear[gearNumber].color;
        }
        return '#585858';
      }
    },
    dashoffset() {
      return 330 + this.speedometer.noss.percentage * 2.35;
    },
    currentStats() {
      return this.getType === 'civilian' ? this.getStats['civilian'] : this.getStats['car'];
    }
  },

  watch: {
    'hud.hunger.percentage': function(val) {
      if (val) this.connected = true;
    },
    selectedGear: function(gear) {
      if (gear == 0) this.selectedGear = "N";
    },
    'speedometer.rpm.percentage': function(val) {
      if (!this.isUpdating) {
        this.isUpdating = true;
        setTimeout(() => {
          this.isUpdating = false;
          this.speedometer.rpm.percentage = Math.max(0, this.speedometer.rpm.percentage - 1);
        }, 25); 
      }
    },
    getType(value) {
      this.mapSet(value);
    }
  }
});

document.onkeyup = function(data) {
  if (data.which == 27 && app.menu) {
    app.menu(false);
    $.post(`https://${GetParentResourceName()}/exit`, JSON.stringify({}));
  }
};

  