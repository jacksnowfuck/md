<script setup lang="ts">
import { Button } from '@/components/ui/button'
// 确保导入所有需要的 UI 组件
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Separator } from '@/components/ui/separator'

import { useDisplayStore, useStore } from '@/stores'
import { ref, watch } from 'vue'
import 'codemirror/addon/search/search'
import 'codemirror/addon/search/searchcursor'

const store = useStore()
const displayStore = useDisplayStore()

const searchText = ref(``)
const replaceText = ref(``)
const currentMatch = ref(0)
const totalMatches = ref(0)

// 预设的关键字列表
const presetKeywords = [
  { search: `在工作中，`, replace: `` },
  { search: `总之，`, replace: `` },
  { search: `例如，`, replace: `` },
  { search: `同时，`, replace: `` },
  { search: `综上所述，`, replace: `` },
  { search: `因此，`, replace: `` },
  { search: `所以，`, replace: `` },
  { search: `另外，`, replace: `` },
  { search: `此外，`, replace: `` },
  { search: `接下来，`, replace: `` },
  { search: `首先，`, replace: `` },
  { search: `其次，`, replace: `` },
  { search: `最后，`, replace: `` },
  { search: `显然，`, replace: `` },
  { search: `事实上，`, replace: `` },
]

// 查找所有匹配项
function findAll() {
  if (!searchText.value) {
    toast.error(`请输入要查找的内容`)
    return
  }

  const editor = store.editor
  if (!editor)
    return

  let count = 0
  const cursor = editor.getSearchCursor(searchText.value)

  // 重置编辑器选中状态
  editor.setSelection(editor.getCursor(`start`))

  while (cursor.findNext()) {
    count++
    // 高亮第一个匹配项
    if (count === 1) {
      editor.setSelection(cursor.from(), cursor.to())
      editor.scrollIntoView(cursor.from())
    }
  }

  totalMatches.value = count
  currentMatch.value = count > 0 ? 1 : 0

  if (count === 0) {
    toast.error(`未找到匹配内容`)
  }
}

// 查找下一个
function findNext() {
  const editor = store.editor
  if (!editor)
    return

  const cursor = editor.getSearchCursor(searchText.value, editor.getCursor(`to`))

  if (cursor.findNext()) {
    editor.setSelection(cursor.from(), cursor.to())
    editor.scrollIntoView(cursor.from())
    currentMatch.value = currentMatch.value % totalMatches.value + 1
  }
  else {
    // 到达末尾,从头开始
    const cursor = editor.getSearchCursor(searchText.value)
    if (cursor.findNext()) {
      editor.setSelection(cursor.from(), cursor.to())
      editor.scrollIntoView(cursor.from())
      currentMatch.value = 1
    }
  }
}

// 查找上一个
function findPrev() {
  const editor = store.editor
  if (!editor)
    return

  const cursor = editor.getSearchCursor(searchText.value, editor.getCursor(`from`))

  if (cursor.findPrevious()) {
    editor.setSelection(cursor.from(), cursor.to())
    editor.scrollIntoView(cursor.from())
    currentMatch.value = currentMatch.value === 1 ? totalMatches.value : currentMatch.value - 1
  }
  else {
    // 到达开头,从末尾开始
    const cursor = editor.getSearchCursor(searchText.value)
    let last
    while (cursor.findNext()) {
      last = { from: cursor.from(), to: cursor.to() }
    }
    if (last) {
      editor.setSelection(last.from, last.to)
      editor.scrollIntoView(last.from)
      currentMatch.value = totalMatches.value
    }
  }
}

// 替换当前
function replaceCurrent() {
  const editor = store.editor
  if (!editor || !searchText.value)
    return

  const cursor = editor.getSearchCursor(searchText.value, editor.getCursor(`from`))
  if (cursor.findNext()) {
    cursor.replace(replaceText.value)
    findNext() // 查找下一个
  }
}

// 替换所有
function replaceAll() {
  if (!searchText.value) {
    toast.error(`请输入要查找的内容`)
    return
  }

  const editor = store.editor
  if (!editor)
    return

  const content = editor.getValue()
  const newContent = content.replaceAll(searchText.value, replaceText.value)
  editor.setValue(newContent)

  displayStore.isShowReplaceDialog = false
  toast.success(`替换完成`)
}

// 一键删除所有过渡词
function removeAllTransitionalWords() {
  const editor = store.editor
  if (!editor)
    return

  let content = editor.getValue()

  // 遍历所有预设关键字进行替换
  presetKeywords.forEach((keyword) => {
    content = content.replaceAll(keyword.search, keyword.replace)
  })

  editor.setValue(content)
  displayStore.isShowReplaceDialog = false
  toast.success(`已删除所有过渡词`)
}

function onUpdate(val: boolean) {
  if (!val) {
    displayStore.isShowReplaceDialog = false
  }
}

// 监听搜索文本变化
watch(searchText, () => {
  if (searchText.value) {
    findAll()
  }
  else {
    totalMatches.value = 0
    currentMatch.value = 0
  }
})

// 添加调试
watch(() => displayStore.isShowReplaceDialog, (val) => {
  console.log(`Dialog visibility changed:`, val)
})

// 选择预设关键字
function selectPreset(keyword: { search: string, replace: string }) {
  searchText.value = keyword.search
  replaceText.value = keyword.replace
  findAll() // 立即执行查找
}
</script>

<template>
  <Dialog :open="displayStore.isShowReplaceDialog" @update:open="onUpdate">
    <DialogContent class="min-w-[500px]">
      <DialogHeader>
        <DialogTitle>查找替换</DialogTitle>
      </DialogHeader>

      <!-- 预设关键字列表 -->
      <div class="mb-4">
        <div class="mb-2 flex items-center justify-between">
          <Label>常用过渡词</Label>
          <Button
            variant="destructive"
            size="sm"
            @click="removeAllTransitionalWords"
          >
            一键删除文内下述全部过渡词
          </Button>
        </div>
        <div class="flex flex-wrap gap-2">
          <Button
            v-for="keyword in presetKeywords"
            :key="keyword.search"
            variant="outline"
            size="sm"
            class="text-sm"
            @click="selectPreset(keyword)"
          >
            {{ keyword.search }}
          </Button>
        </div>
      </div>

      <Separator class="my-4" />

      <!-- 原有的查找替换表单 -->
      <div class="space-y-4">
        <div class="space-y-2">
          <div class="flex items-center justify-between">
            <Label>查找内容</Label>
            <span v-if="totalMatches" class="text-sm text-gray-500">
              {{ currentMatch }}/{{ totalMatches }}
            </span>
          </div>
          <div class="flex gap-2">
            <Input v-model="searchText" placeholder="请输入要查找的内容" />
            <Button variant="outline" class="shrink-0" @click="findPrev">
              ↑
            </Button>
            <Button variant="outline" class="shrink-0" @click="findNext">
              ↓
            </Button>
          </div>
        </div>
        <div class="space-y-2">
          <Label>替换为</Label>
          <Input v-model="replaceText" placeholder="请输入要替换的内容" />
        </div>
      </div>

      <DialogFooter>
        <Button variant="outline" @click="displayStore.isShowReplaceDialog = false">
          取消
        </Button>
        <Button variant="outline" @click="replaceCurrent">
          替换当前
        </Button>
        <Button @click="replaceAll">
          替换全部
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>
