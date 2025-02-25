import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useDisplayStore = defineStore(`display`, () => {
  const isShowReplaceDialog = ref(false)

  return {
    isShowReplaceDialog,
    toggleShowReplaceDialog: () => isShowReplaceDialog.value = !isShowReplaceDialog.value,
  }
})
