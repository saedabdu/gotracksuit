/**
 * Minimal replacement for classnames and clsx
 */
export const cx = (...args: (string | boolean | undefined | null)[]) => {
  return args.filter(Boolean).join(" ");
};
