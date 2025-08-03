// tests/royalty-splits.test.ts
import { describe, it, expect, beforeEach, vi } from 'vitest'

type Split = {
  recipient: string
  share: number
}

let mockWorkId = 0
let registeredWorks: Record<number, { splits: Split[]; owner: string; balance: number }> = {}

function registerWork(owner: string, splits: Split[]) {
  const total = splits.reduce((acc, s) => acc + s.share, 0)
  if (total !== 100) return { ok: false, error: 'Total shares must be 100%' }
  registeredWorks[mockWorkId] = { splits, owner, balance: 0 }
  return { ok: true, workId: mockWorkId++ }
}

function setSplits(workId: number, splits: Split[]) {
  registeredWorks[workId].splits = splits
  return { ok: true }
}

function deposit(workId: number, amount: number) {
  registeredWorks[workId].balance += amount
  return { ok: true }
}

function claim(workId: number, recipient: string) {
  const work = registeredWorks[workId]
  const split = work.splits.find((s) => s.recipient === recipient)
  if (!split) return { ok: false, error: 'Not authorized' }
  const amount = (work.balance * split.share) / 100
  return { ok: true, amount }
}

function transferOwnership(workId: number, newOwner: string) {
  registeredWorks[workId].owner = newOwner
  return { ok: true }
}

beforeEach(() => {
  mockWorkId = 0
  registeredWorks = {}
})

describe('Royalty Splits', () => {
  it('registerWork succeeds with 100% share split', () => {
    const result = registerWork('ST123', [
      { recipient: 'ST456', share: 60 },
      { recipient: 'ST789', share: 40 },
    ])
    expect(result.ok).toBe(true)
    expect(result.workId).toBe(0)
  })

  it('registerWork fails if shares do not sum to 100%', () => {
    const result = registerWork('ST123', [
      { recipient: 'ST456', share: 50 },
      { recipient: 'ST789', share: 30 },
    ])
    expect(result.ok).toBe(false)
  })

  it('setSplits works when total is 100%', () => {
    registerWork('ST123', [
      { recipient: 'ST456', share: 60 },
      { recipient: 'ST789', share: 40 },
    ])
    const result = setSplits(0, [
      { recipient: 'ST456', share: 70 },
      { recipient: 'ST789', share: 30 },
    ])
    expect(result.ok).toBe(true)
  })

  it('deposit succeeds', () => {
    registerWork('ST123', [
      { recipient: 'ST456', share: 60 },
      { recipient: 'ST789', share: 40 },
    ])
    const result = deposit(0, 1000)
    expect(result.ok).toBe(true)
  })

  it('claim returns amount', () => {
    registerWork('ST123', [
      { recipient: 'ST456', share: 60 },
      { recipient: 'ST789', share: 40 },
    ])
    deposit(0, 1000)
    const result = claim(0, 'ST456')
    expect(result.ok).toBe(true)
    expect(result.amount).toBe(600)
  })

  it('transferOwnership succeeds', () => {
    registerWork('ST123', [
      { recipient: 'ST456', share: 60 },
      { recipient: 'ST789', share: 40 },
    ])
    const result = transferOwnership(0, 'ST000')
    expect(result.ok).toBe(true)
  })
})
