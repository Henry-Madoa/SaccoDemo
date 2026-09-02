import { redirect } from 'next/navigation';

/** Banker's cheque types are managed in the Admin Centre → Setup Pool → FOSA. */
export default function ChequeTypesRedirect() {
  redirect('/admin/pool/fosa/bankers-cheque-types');
}
